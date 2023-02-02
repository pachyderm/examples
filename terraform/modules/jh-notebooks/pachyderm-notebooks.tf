terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.25.0"
    }
  }
}

resource "helm_release" "pachyderm_jupyterhub" {
  name            = "${var.project_name}-jupyterhub"
  repository      = "https://jupyterhub.github.io/helm-chart/"
  chart           = "jupyterhub"
  version         = var.jupyter_version
  namespace       = var.notebooks_namespace
  create_namespace = true
  cleanup_on_fail = true
  atomic          = true
  timeout         = 200
  values = [
    templatefile("${path.module}/jupyterhub-values.yaml.tftpl", {
      OAUTH2_AUTHORIZE_URL   = "${var.okta_oidc_issuer}/v1/authorize",
      OAUTH2_TOKEN_URL       = "${var.okta_oidc_issuer}/v1/token",
      OAUTH2_USERDATA_URL    = "${var.okta_oidc_issuer}/v1/userinfo",
      OAUTH_CALLBACK_URL     = "http://${var.notebook_dns_name}/hub/oauth_callback",
      OAUTH_CLIENT_ID        = var.okta_oidc_client_id,
      OAUTH_CLIENT_SECRET    = var.okta_oidc_client_secret,
      NOTEBOOK_DNS_NAME      = var.notebook_dns_name,
      HUB_ADMIN_USER         = var.admin_user,
      NOTEBOOKS_USER_VERSION = var.notebooks_user_version,
      MOUNT_SERVER_IMAGE     = var.mount_server_image,
      NAMESPACE              = var.namespace,
    })
  ]
}

data "kubernetes_service" "notebooks_proxy" {
  metadata {
    name      = "proxy-public"
    namespace = var.notebooks_namespace
  }
  depends_on = [
    helm_release.pachyderm_jupyterhub,
  ]
}


resource "cloudflare_record" "notebook_cname" {
  zone_id         = var.cloudflare_zone_id
  name            = var.notebook_dns_name
  value           = data.kubernetes_service.notebooks_proxy.status[0].load_balancer[0].ingress[0].hostname
  type            = "CNAME"
  ttl             = 1
  proxied         = true
  allow_overwrite = true
}
