variable "index" {
    type = number
    description = "UUID for the project"
}

variable "name" {
    type = string
    description = "Name of the project"
}

variable "aws_region" {
    type = string
    description = "AWS region for the project"
    default = "us-east-2"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "cluster_version" {
  type    = string
  default = "1.24"
}

variable "project_name" {
  type        = string
  description = "name of the project"
}

variable "enable_karpenter" {
  type        = bool
  description = "enable karpenter"
  default     = false
}

variable "enable_cloudflare" {
  type        = bool
  description = "enable cloudflare"
  default     = false
}

variable "enable_notebooks" {
  type        = bool
  description = "enable notebooks"
  default     = false
}

###############################################################################
# DATABASE VARIABLES
###############################################################################

variable "db_version" {
  type        = string
  description = "version of postgresql to use"
  default     = "14.5"
}

variable "db_instance_class" {
  type        = string
  description = "db instance class"
  default     = "db.m6g.4xlarge"
}

variable "db_username" {
  type        = string
  description = "database username"
  default     = "postgres"
}

variable "db_password" {
  type        = string
  description = "database password"
  default     = "insecure-user-password"
}

variable "db_auth_type" {
  type        = string
  description = "database authentication type. Postgresql versions 13 and below use md5, 14 and above use scram-sha-256"
  default     = "scram-sha-256"
}

variable "db_iops" {
  type        = number
  description = "iops for db"
  default     = 5000
}

variable "db_storage" {
  type        = number
  description = "storage for db"
  default     = 500
}

variable "db_max_storage" {
  type        = number
  description = "max storage for db"
  default     = 2000
}

###############################################################################
# LAUNCH TEMPLATE VARIABLES
###############################################################################
variable "lt_ebs_optimized" {
  type        = string
  description = "t/f ebs optimized"
  default     = "true"
}

variable "lt_block_ebs_iops" {
  type        = number
  description = "node storage iops"
  default     = 10000
}

variable "lt_block_ebs_size" {
  type        = number
  description = "node storage size"
  default     = 1000
}

variable "lt_block_ebs_type" {
  type        = string
  description = "node storage type"
  default     = "gp3"
}

variable "lt_block_ebs_throughput" {
  type        = number
  description = "node storage throughput"
  default     = 750
}

###############################################################################
# NODE POOL VARIABLES
###############################################################################

variable "ami_type" {
    type = string
    description = "The AMI type for your node group. GPU instance types should use the AL2_x86_64_GPU AMI type. Non-GPU instances should use the AL2_x86_64 AMI type. Defaults to AL2_x86_64."
    default = "AL2_x86_64"
}

variable "node_capacity_type" {
  type        = string
  description = "node pool capacity type (ON_DEMAND or SPOT)"
  default     = "ON_DEMAND"
}

variable "node_instance_types" {
  type        = list(string)
  description = "node pool instance types (e.g. m5.2xlarge)"
  default     = ["m5.2xlarge"]
}

variable "max_nodes" {
  type        = number
  description = "max nodes"
  default     = 1
}

variable "min_nodes" {
  type        = number
  description = "min nodes"
  default     = 1
}

variable "desired_nodes" {
  type        = number
  description = "desired nodes (must be between min and max)"
  default     = 1
}

variable "node_timeout" {
  type        = string
  description = "node pool creation/deletion/update timeout"
  default     = "15m"
}

###############################################################################
# VPC VARIABLES
###############################################################################

variable "vpc_cidr_block" {
  type        = string
  description = "vpc cidr block"
  default     = "10.0.0.0/16"
}
variable "subnet_cidr_blocks" {
  type        = list(string)
  description = "list of subnet cidr blocks"
  default     = ["10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19", "10.0.128.0/19"]
}

variable "private_destination_cidr_block" {
  type        = string
  description = "private destination cidr block"
  default     = "0.0.0.0/0"
}

variable "public_destination_cidr_block" {
  type        = string
  description = "public destination cidr block"
  default     = "0.0.0.0/0"
}


###############################################################################
# HELM VARIABLES
###############################################################################
variable "namespace" {
  type    = string
  default = "default"
}

variable "pach_version" {
  type    = string
  default = "2.4.4"
}

variable "pachd_image_repo" {
  type    = string
  default = "pachyderm/pachd"
}

variable "pachd_image_tag" {
  type    = string
  default = "2.4.4"
}

variable "worker_image_repo" {
  type    = string
  default = "pachyderm/worker"
}

variable "worker_image_tag" {
  type    = string
  default = "2.4.4"
}

variable "console_image_tag" {
  type    = string
  default = "2.4.4-1"
}

variable "loki_storage_size" {
  type    = string
  default = "10Gi"
}

variable "loki_storage_class" {
  type    = string
  default = "gp2"
}

variable "console_oauth_client_secret" {
  type    = string
  default = "console-supersecret"
}

variable "log_level" {
  type    = string
  default = "info"
}

variable "loki_deploy" {
  type    = bool
  default = true
}

variable "loki_logging" {
  type    = bool
  default = true
}

variable "enterprise_license_key" {
  type        = string
  description = "value of the license key for the enterprise version of Pachyderm"
}

variable "root_token" {
  type    = string
  default = "root-supersecret"
}

variable "cluster_deployment_id" {
  type    = string
  default = "cluster-id-supersecret"
}

variable "enterprise_secret" {
  type    = string
  default = "enterprise-supersecret"
}

variable "oauth_client_secret" {
  type    = string
  default = "oauth-supersecret"
}

variable "pachd_cpu_request" {
  type    = number
  default = 2
}

variable "pachd_memory_request" {
  type    = string
  default = "2G"
}

variable "etcd_cpu_request" {
  type    = number
  default = 6
}

variable "etcd_memory_request" {
  type    = string
  default = "4G"
}

variable "etcd_storage_class" {
  type    = string
  default = "gp3"
}

variable "etcd_storage_size" {
  type    = string
  default = "50G"
}

variable "pgbouncer_max_connections" {
  type    = number
  default = 10000
}

variable "pgbouncer_default_pool_size" {
  type    = number
  default = 500
}

variable "admin_user" {
  type        = string
  description = "username of the admin user"
}

variable "dns_name" {
  type        = string
  description = "value of the dns name for the pachyderm cluster ex. console.pachaform.com"
}

variable "okta_oidc_issuer" {
  type        = string
  description = "enter oidc issuer url ex. https://pachaform.okta.com/oauth2/default"
}

variable "okta_oidc_client_id" {
  type        = string
  description = "enter oidc_clientID"
}

variable "okta_oidc_client_secret" {
  type        = string
  description = "enter oidc_clientSecret"
}

variable "github_oidc_client_id" {
  type        = string
  description = "enter oidc_clientID"
}

variable "github_oidc_client_secret" {
  type        = string
  description = "enter oidc_clientSecret"
}

variable "cloudflare_api_token" {
  type        = string
  description = "value of the cloudflare api token"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "value of the cloudflare zone id"
}

###############################################################################
# NOTEBOOK VARIABLES
###############################################################################

variable "notebook_dns_name" {
  type        = string
  description = "value of the dns name for the pachyderm notebook ex. notebook.pachaform.com"
}

variable "jupyter_version" {
  type    = string
  default = "2.0.0"
}

variable "notebooks_user_version" {
  type    = string
  default = "v2.4.3"
}

variable "mount_server_image" {
  type    = string
  default = "pachyderm/mount-server:2.4.3"
}

variable "notebooks_namespace" {
  type    = string
  default = "default"
}

###############################################################################
# KARPENTER VARIABLES
###############################################################################

variable "karpenter_service_account_create" {
  type    = bool
  default = true
}

variable "karpenter_service_account_name" {
  type    = string
  default = "karpenter"
}