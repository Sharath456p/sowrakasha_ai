terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    # The bucket name will be passed via backend config in the pipeline 
    # or hardcoded here if we know it. 
    # For now, we leave partial config or use a variable approach in init.
    # BEST PRACTICE for this setup: Hardcode it after bootstrap because it doesn't change for the project.
    bucket  = "sowrakasha-ai-platform-tfshell"
    prefix  = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ENABLE APIS
resource "google_project_service" "container" {
  service = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

# VPC NETWORK
resource "google_compute_network" "vpc" {
  name                    = "sowrakasha-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "sowrakasha-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.0.0.0/16"
  
  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.1.0.0/16"
  }
  
  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# GKE CLUSTER
resource "google_container_cluster" "primary" {
  name     = "sowrakasha-cluster"
  location = "${var.region}-a" # Zonal = Cheaper
  
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id
  
  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  deletion_protection = false 
}
