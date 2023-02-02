variable "region" {
  type    = string
}

variable "project_name" {
  type        = string
  description = "name of the project"
}

variable "admin_user" {
  type        = string
  description = "username of the admin user"
}

variable "cluster_iam_role_name" {
  type        = string
  description = "name of the cluster iam role"
}

variable "vpc_cidr_block" {
  type        = string
  description = "vpc cidr block"
}
variable "subnet_cidr_blocks" {
  type        = list(string)
  description = "list of subnet cidr blocks"
}

variable "private_destination_cidr_block" {
  type        = string
  description = "private destination cidr block"
}

variable "public_destination_cidr_block" {
  type        = string
  description = "public destination cidr block"
}
