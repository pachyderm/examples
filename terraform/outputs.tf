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
output "console_web_endpoint"{
  value = data.kubernetes_service.ingress.status[0].load_balancer[0].ingress[0].hostname
}
