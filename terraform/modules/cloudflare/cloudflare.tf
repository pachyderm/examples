terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.25.0"
    }
  }
}

resource "cloudflare_record" "console_cname" {
  zone_id         = var.cloudflare_zone_id
  name            = var.dns_name
  value           = data.kubernetes_service.pachd_proxy.status[0].load_balancer[0].ingress[0].hostname
  type            = "CNAME"
  ttl             = 1
  proxied         = true
  allow_overwrite = true
}

data "kubernetes_service" "pachd_proxy" {
  metadata {
    name      = "pachyderm-proxy"
    namespace = var.namespace
  }
}