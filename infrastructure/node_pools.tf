# SYSTEM NODE POOL
resource "google_container_node_pool" "system_nodes" {
  name       = "system-pool"
  location   = "${var.region}-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "e2-standard-2"

    # Use the Service Account specific for GKE nodes (passed as var or created here? 
    # Let's create a NODE SA here, separate from the GHA SA.
    service_account = google_service_account.node_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# GPU INFERENCE POOL
resource "google_container_node_pool" "gpu_inference_nodes" {
  name     = "gpu-inference-pool"
  location = "${var.region}-a"
  cluster  = google_container_cluster.primary.name

  autoscaling {
    min_node_count = 0 
    max_node_count = 3
  }

  node_config {
    spot = true
    machine_type = "n1-standard-4" 
    
    guest_accelerator {
      type  = "nvidia-tesla-t4"
      count = 1
    }

    taint {
      key    = "nvidia.com/gpu"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    service_account = google_service_account.node_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# Dedicated Service Account for the Cluster Nodes (NOT the one Terraform uses to deploy)
resource "google_service_account" "node_sa" {
  account_id   = "sowrakasha-node-sa"
  display_name = "GKE Node Service Account"
}
