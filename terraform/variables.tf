variable "region" {
  type    = string
  default = "us-east-2"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "cluster_version" {
  type    = string
  default = "1.23"
}

variable "project_name" {
  type        = string
  description = "name of the project"
}

###############################################################################
# DATABASE VARIABLES
###############################################################################

variable "db_version" {
  type        = string
  description = "version of postgresql to use"
  default     = "14.2"
}

variable "db_instance_class" {
  type        = string
  description = "db instance class"
  default     = "db.m6g.xlarge"
}

variable "db_username" {
  type        = string
  description = "database username"
  default     = "postgres"
}

variable "db_password" {
  type        = string
  description = "database password"
  default     = "supersecretpassword"
}

variable "db_iops" {
  type        = number
  description = "iops for db"
  default     = 1001
}

variable "db_storage" {
  type        = number
  description = "storage for db"
  default     = 100
}

variable "db_max_storage" {
  type        = number
  description = "max storage for db"
  default     = 200
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
  default     = 1000
}

variable "lt_block_ebs_size" {
  type        = number
  description = "node storage size"
  default     = 200
}

variable "lt_block_ebs_type" {
  type        = string
  description = "node storage type"
  default     = "gp3"
}

variable "lt_block_ebs_throughput" {
  type        = number
  description = "node storage throughput"
  default     = 250
}

###############################################################################
# NODE POOL VARIABLES
###############################################################################

variable "node_capacity_type" {
  type        = string
  description = "node pool capacity type (ON_DEMAND or SPOT)"
  default     = "ON_DEMAND"
}

variable "node_instance_types" {
  type        = list(string)
  description = "node pool instance types (e.g. m5.2xlarge)"
  default     = ["m5.large"]
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
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
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
  default = "2.3.3"
}

variable "pachd_image_tag" {
  type    = string
  default = "2.3.3"
}

variable "console_image_tag" {
  type    = string
  default = "2.3.3-1"
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
  default = "supersecret"
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
  default     = ""
}

variable "root_token" {
  type    = string
  default = "supersecret"
}

variable "cluster_deployment_id" {
  type    = string
  default = "supersecret"
}

variable "enterprise_secret" {
  type    = string
  default = "supersecret"
}

variable "oauth_client_secret" {
  type    = string
  default = "supersecret"
}

variable "pachd_cpu_request" {
  type    = number
  default = 1
}

variable "pachd_memory_request" {
  type    = string
  default = "1Gi"
}

variable "etcd_cpu_request" {
  type    = number
  default = 1
}

variable "etcd_memory_request" {
  type    = string
  default = "1Gi"
}

variable "etcd_storage_class" {
  type    = string
  default = "gp3"
}

variable "etcd_storage_size" {
  type    = string
  default = "10Gi"
}

variable "pgbouncer_max_connections" {
  type    = number
  default = 1000
}

variable "pgbouncer_default_pool_size" {
  type    = number
  default = 100
}

variable "dns_name" {
  type        = string
  description = "value of the dns name for the pachyderm cluster ex. console.pachaform.com"
}

variable "oidc_issuer" {
  type        = string
  description = "enter oidc issuer url ex. https://pachaform.okta.com/oauth2/default"
}

variable "oidc_client_id" {
  type        = string
  description = "enter oidc_clientID"
}

variable "oidc_client_secret" {
  type        = string
  description = "enter oidc_clientSecret"
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
  default = "1.2.0"
}

variable "notebooks_user_version" {
  type    = string
  default = "v0.6.0"
}

variable "mount_server_image" {
  type    = string
  default = "pachyderm/mount-server:2.3.0-994b6f6553ff265ca128c8fb4fec825be87a972a"
}

variable "hub_admin_user" {
  type        = string
  description = "username of the hub admin user"
  default     = "brody.osterbuhr@pachyderm.io"
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