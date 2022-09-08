resource "helm_release" "pachaform" {
  name            = var.project_name
  repository      = "https://helm.pachyderm.com"
  chart           = "pachyderm"
  version         = var.pach_version
  namespace       = var.namespace
  cleanup_on_fail = true
  atomic          = true
  values = [
    templatefile("${path.module}/values.yaml.tftpl", {
      PROJECT_SECRETS             = kubernetes_secret_v1.pachaform_secrets.metadata[0].name
      POSTGRESQL_USERNAME         = var.db_username,
      POSTGRESQL_PASSWORD         = var.db_password,
      POSTGRESQL_DATABASE         = "pachyderm",
      POSTGRESQL_HOST             = aws_db_instance.pachaform_postgres.address,
      LOKI_STORAGE_SIZE           = var.loki_storage_size,
      LOKI_STORAGE_CLASS          = var.loki_storage_class,
      LOG_LEVEL                   = var.log_level,
      LOKI_DEPLOY                 = var.loki_deploy,
      LOKI_LOGGING                = var.loki_logging,
      CLUSTER_DEPLOYMENT_ID       = var.cluster_deployment_id,
      BUCKET_ROLE_ARN             = aws_iam_role.pachaform_s3_role.arn,
      BUCKET_NAME                 = aws_s3_bucket.pachaform_s3_bucket.id,
      AWS_REGION                  = var.region,
      CONSOLE_IMAGE_TAG           = var.console_image_tag,
      PACHD_IMAGE_TAG             = var.pachd_image_tag,
      PACHD_CPU_REQUEST           = var.pachd_cpu_request,
      PACHD_MEMORY_REQUEST        = var.pachd_memory_request,
      ETCD_STORAGE_CLASS          = var.etcd_storage_class,
      ETCD_STORAGE_SIZE           = var.etcd_storage_size,
      ETCD_CPU_REQUEST            = var.etcd_cpu_request,
      ETCD_MEMORY_REQUEST         = var.etcd_memory_request,
      PGBOUNCER_MAX_CONNECTIONS   = var.pgbouncer_max_connections,
      PGBOUNCER_DEFAULT_POOL_SIZE = var.pgbouncer_default_pool_size,
      DNS_NAME                    = var.dns_name,
    })
  ]
  depends_on = [
    aws_eks_node_group.pachaform_nodes,
    aws_db_instance.pachaform_postgres,
    aws_s3_bucket.pachaform_s3_bucket,
    postgresql_database.dex,
    postgresql_grant.full_crud_pachyderm,
    postgresql_grant.full_crud_dex,
  ]
}

resource "null_resource" "pachctl_context" {
  depends_on = [
    helm_release.pachaform,
    data.kubernetes_service.pachd_proxy,
  ]
  provisioner "local-exec" {
    command = <<EOT
    pachctl config import-kube $NAME --overwrite
    EOT
    environment = {
      NAME  = var.project_name
    }
  }

}

resource "helm_release" "pachyderm_jupyterhub" {
  name            = "${var.project_name}-jupyterhub"
  repository      = "https://jupyterhub.github.io/helm-chart/"
  chart           = "jupyterhub"
  version         = var.jupyter_version
  namespace       = var.namespace
  cleanup_on_fail = true
  atomic          = true
  values = [
    templatefile("${path.module}/jupyterhub-values.yaml.tftpl", {
        OAUTH2_AUTHORIZE_URL = "${var.oidc_issuer}/v1/authorize",
        OAUTH2_TOKEN_URL     = "${var.oidc_issuer}/v1/token",
        OAUTH2_USERDATA_URL  = "${var.oidc_issuer}/v1/userinfo",
        OAUTH_CALLBACK_URL = "http://${var.notebook_dns_name}/hub/oauth_callback",
        OAUTH_CLIENT_ID = var.oidc_client_id,
        OAUTH_CLIENT_SECRET = var.oidc_client_secret,
        NOTEBOOK_DNS_NAME = var.notebook_dns_name,
        HUB_ADMIN_USER = var.hub_admin_user,
        NOTEBOOKS_USER_VERSION = var.notebooks_user_version,
        MOUNT_SERVER_IMAGE = var.mount_server_image,
    })
  ]
  depends_on = [
    helm_release.pachaform,
  ]
}
