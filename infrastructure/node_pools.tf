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

# CPU INFERENCE POOL (Fallback)
# PURPOSE: Running vLLM / Ollama on CPU since GPU quota is 0.
# COST: Very Low (Spot Instances).
resource "google_container_node_pool" "cpu_inference_nodes" {
  name     = "cpu-inference-pool"
  location = "${var.region}-a"
  cluster  = google_container_cluster.primary.name

  autoscaling {
    min_node_count = 0
    max_node_count = 3
  }

  node_config {
    spot = true
    machine_type = "e2-standard-4" # 4 vCPU, 16GB RAM. Fits quantized 7B/8B models.

    # User requested CPU only for speed.
    # No Guest Accelerator.
    # No Taints (easier scheduling).

    labels = {
      "workload" = "inference"
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
