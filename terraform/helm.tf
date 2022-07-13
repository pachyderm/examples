resource "helm_release" "pachaform" {
  name            = "pachaform"
  repository      = "https://helm.pachyderm.com"
  chart           = "pachyderm"
  version         = var.pach_version
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
      PGBOUNCER_DEFAULT_POOL_SIZE = var.pgbouncer_default_pool_size
    })
  ]
  depends_on = [
    aws_eks_node_group.pachaform-nodes,
    aws_db_instance.pachaform-postgres,
    aws_s3_bucket.pachaform-s3-bucket,
    postgresql_database.dex,
    postgresql_grant.full-crud-pachyderm,
    postgresql_grant.full-crud-dex
  ]
}