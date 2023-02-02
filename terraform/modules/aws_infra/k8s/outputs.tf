output "gp3" {
    value = kubernetes_storage_class.gp3
}

output "pachyderm_secrets" {
    value = kubernetes_secret_v1.pachyderm_secrets
}

output "pachyderm_secrets_name" {
    value = kubernetes_secret_v1.pachyderm_secrets.metadata[0].name
}