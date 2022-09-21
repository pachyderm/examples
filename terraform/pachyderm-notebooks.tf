# resource "helm_release" "pachyderm_jupyterhub" {
#   name            = "${var.project_name}-jupyterhub"
#   repository      = "https://jupyterhub.github.io/helm-chart/"
#   chart           = "jupyterhub"
#   version         = var.jupyter_version
#   namespace       = var.namespace
#   cleanup_on_fail = true
#   atomic          = true
#   timeout         = 600
#   values = [
#     templatefile("${path.module}/jupyterhub-values.yaml.tftpl", {
#       OAUTH2_AUTHORIZE_URL   = "${var.oidc_issuer}/v1/authorize",
#       OAUTH2_TOKEN_URL       = "${var.oidc_issuer}/v1/token",
#       OAUTH2_USERDATA_URL    = "${var.oidc_issuer}/v1/userinfo",
#       OAUTH_CALLBACK_URL     = "http://${var.notebook_dns_name}/hub/oauth_callback",
#       OAUTH_CLIENT_ID        = var.oidc_client_id,
#       OAUTH_CLIENT_SECRET    = var.oidc_client_secret,
#       NOTEBOOK_DNS_NAME      = var.notebook_dns_name,
#       HUB_ADMIN_USER         = var.hub_admin_user,
#       NOTEBOOKS_USER_VERSION = var.notebooks_user_version,
#       MOUNT_SERVER_IMAGE     = var.mount_server_image,
#     })
#   ]
#   depends_on = [
#     helm_release.pachaform,
#   ]
# }

