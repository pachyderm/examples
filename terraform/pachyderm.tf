
data "kubernetes_service" "pachd_proxy" {
  metadata {
    name      = "pachyderm-proxy"
    namespace = var.namespace
  }
  depends_on = [
    helm_release.pachaform,
  ]
}

resource "helm_release" "pachaform" {
  name            = var.project_name
  repository      = "https://helm.pachyderm.com"
  chart           = "pachyderm"
  version         = var.pach_version
  namespace       = var.namespace
  cleanup_on_fail = true
  atomic          = false
  values = [
    templatefile("${path.module}/values.yaml.tftpl", {
      PROJECT_SECRETS             = kubernetes_secret_v1.pachaform_secrets.metadata[0].name
      POSTGRESQL_USERNAME         = var.db_username
      POSTGRESQL_DATABASE         = "pachyderm"
      POSTGRESQL_HOST             = aws_db_instance.pachaform_postgres.address
      LOKI_STORAGE_SIZE           = var.loki_storage_size
      LOKI_STORAGE_CLASS          = var.loki_storage_class
      LOG_LEVEL                   = var.log_level
      LOKI_DEPLOY                 = var.loki_deploy
      LOKI_LOGGING                = var.loki_logging
      CLUSTER_DEPLOYMENT_ID       = var.cluster_deployment_id
      BUCKET_ROLE_ARN             = aws_iam_role.pachaform_s3_role.arn
      BUCKET_NAME                 = aws_s3_bucket.pachaform_s3_bucket.id
      AWS_REGION                  = var.region
      CONSOLE_IMAGE_TAG           = var.console_image_tag
      PACHD_IMAGE_REPO            = var.pachd_image_repo
      PACHD_IMAGE_TAG             = var.pachd_image_tag
      WORKER_IMAGE_REPO           = var.worker_image_repo
      WORKER_IMAGE_TAG            = var.worker_image_tag
      PACHD_CPU_REQUEST           = var.pachd_cpu_request
      PACHD_MEMORY_REQUEST        = var.pachd_memory_request
      ETCD_STORAGE_CLASS          = var.etcd_storage_class
      ETCD_STORAGE_SIZE           = var.etcd_storage_size
      ETCD_CPU_REQUEST            = var.etcd_cpu_request
      ETCD_MEMORY_REQUEST         = var.etcd_memory_request
      PGBOUNCER_MAX_CONNECTIONS   = var.pgbouncer_max_connections
      PGBOUNCER_DEFAULT_POOL_SIZE = var.pgbouncer_default_pool_size
      DNS_NAME                    = var.dns_name
      PACH_ADMIN                  = var.admin_user
      NODE_TAG                    = var.node_tag
    })
  ]
  depends_on = [
    helm_release.karpenter,
    kubectl_manifest.karpenter_provisioner,
    aws_eks_node_group.pachaform_nodes,
    aws_eks_addon.pachaform_ebs_driver
  ]
}

resource "null_resource" "pachctl_context" {
  depends_on = [
    helm_release.pachaform,
    data.kubernetes_service.pachd_proxy,
  ]
  provisioner "local-exec" {
    command = <<EOT
    pachctl config import-kube $NAME --overwrite --namespace $NAMESPACE
    EOT
    environment = {
      NAME = var.project_name
      NAMESPACE = var.namespace
    }
  }

}