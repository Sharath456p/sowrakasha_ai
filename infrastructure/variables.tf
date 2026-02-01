variable "project_id" {
  description = "The GCP Project ID. Required for billing and resource creation."
  type        = string
}

variable "region" {
  description = "The GCP Region. Choose 'us-central1' for finding GPUs easily."
  type        = string
  default     = "us-central1"
}

variable "github_repo" {
  description = "The GitHub Repository (username/repo) for Workload Identity trust."
  type        = string
}
