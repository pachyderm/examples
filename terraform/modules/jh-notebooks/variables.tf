variable "region" {
  type    = string
  default = "us-east-2"
}

variable "aws_profile" {
  type    = string
}

variable "project_name" {
  type        = string
  description = "name of the project"
}

###############################################################################
# HELM VARIABLES
###############################################################################
variable "namespace" {
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

variable "cloudflare_api_token" {
  type        = string
  description = "value of the cloudflare api token"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "value of the cloudflare zone id"
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

###############################################################################
# NOTEBOOK VARIABLES
###############################################################################

variable "notebook_dns_name" {
  type        = string
  description = "value of the dns name for the pachyderm notebook ex. notebook.pachaform.com"
}

variable "jupyter_version" {
  type    = string
}

variable "notebooks_user_version" {
  type    = string
}

variable "mount_server_image" {
  type    = string
}

variable "notebooks_namespace" {
  type    = string
}