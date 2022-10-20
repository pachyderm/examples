resource "kubernetes_secret_v1" "pachaform_secrets" {
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

  depends_on = [
    aws_eks_cluster.pachaform_cluster
  ]
}


resource "null_resource" "kubectl" {
  depends_on = [
    aws_eks_cluster.pachaform_cluster,
  ]
  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${aws_eks_cluster.pachaform_cluster.name} --alias ${var.project_name}"
  }
}

