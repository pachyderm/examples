resource "kubernetes_secret_v1" "pachyderm_secrets" {
  metadata {
    name      = "${var.project_name}-secrets"
    namespace = var.namespace
  }

  data = {

    enterprise-secret : var.enterprise_secret,
    root-token : var.root_token,
    pachd-oauth-client-secret : var.oauth_client_secret,
    OAUTH_CLIENT_SECRET : var.oauth_client_secret,
    pachyderm-console-secret : var.console_oauth_client_secret,

    enterprise-license-key : var.enterprise_license_key,
    postgresql_password : var.db_password,
    upstream-idps = yamlencode([
      {
        id : "okta",
        name : "okta",
        type : "oidc",
        jsonConfig : jsonencode({
          "issuer" : var.okta_oidc_issuer,
          "clientID" : var.okta_oidc_client_id,
          "clientSecret" : var.okta_oidc_client_secret,
          "redirectURI" : "http://${var.dns_name}/dex/callback",
          "insecureEnableGroups" : true,
          "insecureSkipEmailVerified" : true,
          "insecureSkipIssuerCallbackDomainCheck" : true,
          "forwardedLoginParams" : ["login_hint"],
          "scopes" : ["groups", "email", "profile"],
          "claimMapping" : {
            "groups" : "groups"
          }
        })
      },
      {
        id : "github",
        name : "GitHub",
        type : "github",
        config : {
          "clientID" : var.github_oidc_client_id,
          "clientSecret" : var.github_oidc_client_secret,
          "redirectURI" : "http://${var.dns_name}/dex/callback",
          "insecureEnableGroups" : true,
          "insecureSkipEmailVerified" : true,
          "insecureSkipIssuerCallbackDomainCheck" : true,
          "scopes" : ["groups", "email", "profile"],
          "claimMapping" : {
            "groups" : "groups"
          }
        }
      }
    ])
  }
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
  }
  storage_provisioner = "ebs.csi.aws.com"
  parameters = {
    type   = "gp3"
    fsType = "ext4"
  }
  volume_binding_mode = "Immediate"
}


resource "null_resource" "kubectl" {
  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name} --alias ${var.project_name}"
  }
}
