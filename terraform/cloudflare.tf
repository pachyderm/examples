# resource "cloudflare_record" "console_cname" {
#   zone_id         = var.cloudflare_zone_id
#   name            = var.dns_name
#   value           = data.kubernetes_service.pachd_proxy.status[0].load_balancer[0].ingress[0].hostname
#   type            = "CNAME"
#   ttl             = 1
#   proxied         = true
#   allow_overwrite = true

#   depends_on = [
#     helm_release.pachaform
#   ]
# }