variable "sg_id" {
    description = "Security group ID"
    type = string
}

variable "ami_type" {
    type = string
    description = "The AMI type for your node group. GPU instance types should use the AL2_x86_64_GPU AMI type. Non-GPU instances should use the AL2_x86_64 AMI type. Defaults to AL2_x86_64."
}

variable "subnet_ids" {
    type = list(string)
    description = "all subnet ids"
}

variable "admin_user" {
  type        = string
  description = "username of the admin user"
}

variable "region" {
  type    = string
}

variable "aws_profile" {
  type    = string
}

variable "cluster_version" {
  type    = string
}

variable "project_name" {
  type        = string
  description = "name of the project"
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
