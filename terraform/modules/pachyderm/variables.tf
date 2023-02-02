variable "region" {
  type    = string
}

variable "project_name" {
  type        = string
  description = "name of the project"
}

variable "pachyderm_secrets_name" {
  type        = string
  description = "pachyderm secrets"
}

variable "s3_role_arn" {
  type        = string
  description = "s3 role arn"
}

variable "s3_bucket_id" {
  type        = string
  description = "s3 bucket id"
}

###############################################################################
# DATABASE VARIABLES
###############################################################################

variable "db_username" {
  type        = string
  description = "database username"
}

variable "db_auth_type" {
  type        = string
  description = "database authentication type. Postgresql versions 13 and below use md5, 14 and above use scram-sha-256"
}

variable "db_host" {
  type        = string
  description = "database host"
}

###############################################################################
# HELM VARIABLES
###############################################################################
variable "namespace" {
  type    = string
}

variable "pach_version" {
  type    = string
}

variable "pachd_image_repo" {
  type    = string
}

variable "pachd_image_tag" {
  type    = string
}

variable "worker_image_repo" {
  type    = string
}

variable "worker_image_tag" {
  type    = string
}

variable "console_image_tag" {
  type    = string
}

variable "loki_storage_size" {
  type    = string
}

variable "loki_storage_class" {
  type    = string
}

variable "log_level" {
  type    = string
}

variable "loki_deploy" {
  type    = bool
}

variable "loki_logging" {
  type    = bool
}

variable "cluster_deployment_id" {
  type    = string
}

variable "pachd_cpu_request" {
  type    = number
}

variable "pachd_memory_request" {
  type    = string
}

variable "etcd_cpu_request" {
  type    = number
}

variable "etcd_memory_request" {
  type    = string
}

variable "etcd_storage_class" {
  type    = string
}

variable "etcd_storage_size" {
  type    = string
}

variable "pgbouncer_max_connections" {
  type    = number
}

variable "pgbouncer_default_pool_size" {
  type    = number
}

variable "admin_user" {
  type        = string
  description = "username of the admin user"
}

variable "dns_name" {
  type        = string
  description = "value of the dns name for the pachyderm cluster ex. console.pachaform.com"
}