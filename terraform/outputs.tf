output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.pachaform-cluster.name
}

output "pach_helm_values" {
  value = helm_release.pachaform.metadata[*].values
}