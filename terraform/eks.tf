resource "aws_iam_role" "pachaform_cluster" {
  name               = "${var.project_name}-cluster"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
      {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "pachaform_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.pachaform_cluster.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "pachaform_AmazonEKSVPCResourceController" {
  role       = aws_iam_role.pachaform_cluster.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_eks_cluster" "pachaform_cluster" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.pachaform_cluster.arn
  version  = var.cluster_version
  vpc_config {
    subnet_ids = [
      aws_subnet.pachaform_private_subnet_1.id,
      aws_subnet.pachaform_private_subnet_2.id,
    ]
    security_group_ids = [
      aws_security_group.pachaform_sg.id,
    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.pachaform_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.pachaform_AmazonEKSVPCResourceController,
    aws_internet_gateway.pachaform_internet_gateway,
    aws_nat_gateway.pachaform_nat_gateway,
    aws_security_group.pachaform_sg,
    aws_route.pachaform_private_route,
    aws_route.pachaform_public_route,
    aws_route_table_association.pachaform_private_rta_1,
    aws_route_table_association.pachaform_private_rta_2,
    aws_db_instance.pachaform_postgres,
  ]
}


data "tls_certificate" "eks" {
  url = aws_eks_cluster.pachaform_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.pachaform_cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

resource "aws_eks_addon" "pachaform_cni" {
  cluster_name      = aws_eks_cluster.pachaform_cluster.name
  addon_name        = "vpc-cni"
  addon_version     = "v1.11.3-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
  tags = {
    Name = "${var.project_name}-vpc-cni"
  }
}

resource "aws_eks_addon" "pachaform_ebs_driver" {
  cluster_name      = aws_eks_cluster.pachaform_cluster.name
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.11.2-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
  tags = {
    Name = "${var.project_name}-ebs-driver"
  }
  depends_on = [
    aws_eks_cluster.pachaform_cluster,
    aws_eks_node_group.pachaform_nodes,
  ]
}

resource "aws_eks_addon" "pachaform_kube_proxy" {
  cluster_name      = aws_eks_cluster.pachaform_cluster.name
  addon_name        = "kube-proxy"
  addon_version     = "v1.23.7-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
  tags = {
    Name = "${var.project_name}-kube-proxy"
  }
}

resource "aws_eks_addon" "pachaform_coredns" {
  cluster_name      = aws_eks_cluster.pachaform_cluster.name
  addon_name        = "coredns"
  addon_version     = "v1.8.7-eksbuild.2"
  resolve_conflicts = "OVERWRITE"
  tags = {
    Name = "${var.project_name}-coredns"
  }
  depends_on = [
    aws_eks_cluster.pachaform_cluster,
    aws_eks_node_group.pachaform_nodes,
  ]
}

