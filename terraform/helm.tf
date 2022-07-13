resource "helm_release" "pachaform" {
  name            = var.project_name
  repository      = "https://helm.pachyderm.com"
  chart           = "pachyderm"
  version         = var.pach_version
  namespace = var.namespace
  cleanup_on_fail = true
  atomic          = true
  values = [
    templatefile("${path.module}/values.yaml.tftpl", {
      POSTGRESQL_USERNAME         = var.db_username,
      POSTGRESQL_PASSWORD         = var.db_password,
      POSTGRESQL_DATABASE         = "pachyderm",
      POSTGRESQL_HOST             = aws_db_instance.pachaform-postgres.address,
      LOKI_STORAGE_SIZE           = var.loki_storage_size,
      LOKI_STORAGE_CLASS          = var.loki_storage_class,
      CONSOLE_OAUTH_CLIENT_SECRET = var.console_oauth_client_secret,
      LOG_LEVEL                   = var.log_level,
      LOKI_DEPLOY                 = var.loki_deploy,
      LOKI_LOGGING                = var.loki_logging,
      ENTERPRISE_LICENSE_KEY      = var.enterprise_license_key,
      ROOT_TOKEN                  = var.root_token,
      CLUSTER_DEPLOYMENT_ID       = var.cluster_deployment_id,
      ENTERPRISE_SECRET           = var.enterprise_secret
      OAUTH_CLIENT_SECRET         = var.oauth_client_secret,
      BUCKET_ROLE_ARN             = aws_iam_role.pachaform-s3-role.arn,
      BUCKET_NAME                 = aws_s3_bucket.pachaform-s3-bucket.id,
      AWS_REGION                  = var.region,
      PACHD_CPU_REQUEST           = var.pachd_cpu_request,
      PACHD_MEMORY_REQUEST        = var.pachd_memory_request,
      ETCD_STORAGE_CLASS          = var.etcd_storage_class,
      ETCD_STORAGE_SIZE           = var.etcd_storage_size,
      ETCD_CPU_REQUEST            = var.etcd_cpu_request,
      ETCD_MEMORY_REQUEST         = var.etcd_memory_request,
      PGBOUNCER_MAX_CONNECTIONS   = var.pgbouncer_max_connections,
      PGBOUNCER_DEFAULT_POOL_SIZE = var.pgbouncer_default_pool_size,
      INGRESS_HOSTNAME            = data.kubernetes_service.ingress.status[0].load_balancer[0].ingress[0].hostname
    })
  ]
  depends_on = [
    aws_eks_node_group.pachaform-nodes,
    aws_db_instance.pachaform-postgres,
    aws_s3_bucket.pachaform-s3-bucket,
    postgresql_database.dex,
    postgresql_grant.full-crud-pachyderm,
    postgresql_grant.full-crud-dex,
    null_resource.nginx_ingress
  ]
}

resource "null_resource" "pachctl-context" {
  depends_on = [
    helm_release.pachaform,
    data.kubernetes_service.pachd_lb
  ]
  provisioner "local-exec" {
    command = <<EOT
    echo '{"pachd_address": "grpc://'$PACHD':30650", "source": 2}' | pachctl config set context $NAME --overwrite
    pachctl config set active-context $NAME
    EOT
    environment = {
      NAME = var.project_name
      PACHD = data.kubernetes_service.pachd_lb.status[0].load_balancer[0].ingress[0].hostname
    }
  }

}
