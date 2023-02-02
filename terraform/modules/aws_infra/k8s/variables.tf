variable "region" {
    type = string
    description = "The region to deploy the cluster"
}

variable "cluster_name" {
    type = string
    description = "The name of the cluster"
}

variable "project_name" {
    type = string
    description = "The name of the project"
}

variable "db_password" {
    type = string
    description = "The password for the database"
}

variable "console_oauth_client_secret" {
  type    = string
}

variable "enterprise_license_key" {
  type        = string
  description = "value of the license key for the enterprise version of Pachyderm"
}

variable "root_token" {
  type    = string
}

variable "cluster_deployment_id" {
  type    = string
}

variable "enterprise_secret" {
  type    = string
}

variable "oauth_client_secret" {
  type    = string
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

variable "namespace" {
  type        = string
  description = "namespace for the pachyderm cluster"
}