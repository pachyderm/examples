output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.pachaform_cluster.name
}

output "pach_helm_values" {
  value = helm_release.pachaform.metadata[*].values
}

output "pachyderm_dns_cname_value" {
  value = data.kubernetes_service.pachd_proxy.status[0].load_balancer[0].ingress[0].hostname
}

# output "notebooks_dns_cname_value" {
#   value = data.kubernetes_service.notebooks_proxy.status[0].load_balancer[0].ingress[0].hostname
# }