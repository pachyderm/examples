output "pach_helm_values" {
  value = helm_release.pachaform.metadata[*].values
}

output "pachyderm_dns_cname_value" {
  value = data.kubernetes_service.pachd_proxy.status[0].load_balancer[0].ingress[0].hostname
}
