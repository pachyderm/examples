variable "eks_oidc_url" {
    type        = string
    description = "enter oidc url"
}

variable "eks_oidc_arn" {
    type        = string
    description = "enter oidc arn"
}

variable "admin_user" {
  type        = string
  description = "username of the admin user"
}

variable "project_name" {
  type        = string
  description = "name of the project"
}