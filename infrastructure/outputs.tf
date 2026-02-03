output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_location" {
  value = google_container_cluster.primary.location
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "ingress_ip_address" {
  value       = google_compute_global_address.ingress_ip.address
  description = "The static global IP address for the Ingress (Point Cloudflare here)"
}
