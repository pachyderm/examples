variable "public_subnet_ids" {
    type = list(string)
    description = "list of public subnet ids"
}

variable "sg_id" {
    type = string
    description = "security group id"
}

variable "admin_user" {
  type        = string
  description = "username of the admin user"
}

variable "project_name" {
  type        = string
  description = "name of the project"
}

variable "nat_gateway_id" {
    type = string
    description = "nat gateway id"
}

variable "public_route_id" {
    type = string
    description = "public route"
}

variable "private_route_id" {
    type = string
    description = "private route"
}

variable "rta_id_list" {
    type = list(string)
    description = "list of route table association ids"
}

###############################################################################
# DATABASE VARIABLES
###############################################################################

variable "db_version" {
  type        = string
  description = "version of postgresql to use"
}

variable "db_instance_class" {
  type        = string
  description = "db instance class"
}

variable "db_username" {
  type        = string
  description = "database username"
}

variable "db_password" {
  type        = string
  description = "database password"
}

variable "db_auth_type" {
  type        = string
  description = "database authentication type. Postgresql versions 13 and below use md5, 14 and above use scram-sha-256"
}

variable "db_iops" {
  type        = number
  description = "iops for db"
}

variable "db_storage" {
  type        = number
  description = "storage for db"
}

variable "db_max_storage" {
  type        = number
  description = "max storage for db"
}
