variable "project_name" {
  type        = string
  description = "name of the project"
}

variable "namespace" {
  type    = string
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
