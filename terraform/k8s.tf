resource "kubernetes_secret_v1" "pachaform-secrets" {
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
    aws_eks_cluster.pachaform-cluster
  ]
}

resource "null_resource" "kubectl" {
  depends_on = [
    aws_eks_cluster.pachaform-cluster,
  ]
  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${aws_eks_cluster.pachaform-cluster.name}"
  }
}

resource "null_resource" "nginx_ingress" {
  depends_on = [
    aws_eks_node_group.pachaform-nodes,
  ]
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/aws/deploy.yaml"
  }
}

data "kubernetes_service" "ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [
    aws_eks_node_group.pachaform-nodes,
    null_resource.nginx_ingress,
  ]
}
data "kubernetes_service" "pachd_lb" {
  metadata {
    name      = "pachd-lb"
    namespace = var.namespace
  }
  depends_on = [
    aws_eks_node_group.pachaform-nodes,
    null_resource.nginx_ingress,
    helm_release.pachaform,
  ]
}
