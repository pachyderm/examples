variable "region" {
  type    = string
}

variable "aws_profile" {
  type    = string
}

variable "project_name" {
  type        = string
  description = "name of the project"
}

variable "cluster_name" {
  type        = string
  description = "name of the cluster"
}

variable "cluster_endpoint" {
  type        = string
  description = "endpoint of the cluster"
}

variable "subnet_ids" {
    type = list(string)
    description = "all subnet ids"
}

variable "sg_id" {
    type = string
    description = "security group id"
}

variable "node_iam_role_name" {
  type        = string
  description = "name of the node iam role"
}

variable "eks_oidc_url" {
  type        = string
  description = "oidc url"
}

variable "eks_oidc_arn" {
  type        = string
  description = "oidc arn"
}

variable "node_iam_role_id" {
  type        = string
  description = "node iam role id"
}

###############################################################################
# LAUNCH TEMPLATE VARIABLES
###############################################################################
variable "lt_ebs_optimized" {
  type        = string
  description = "t/f ebs optimized"
}

variable "lt_block_ebs_iops" {
  type        = number
  description = "node storage iops"
}

variable "lt_block_ebs_size" {
  type        = number
  description = "node storage size"
}

variable "lt_block_ebs_type" {
  type        = string
  description = "node storage type"
}

variable "lt_block_ebs_throughput" {
  type        = number
  description = "node storage throughput"
}

###############################################################################
# KARPENTER VARIABLES
###############################################################################

variable "karpenter_service_account_create" {
  type    = bool
}

variable "karpenter_service_account_name" {
  type    = string
}

variable "admin_user" {
  type        = string
  description = "username of the admin user"
}