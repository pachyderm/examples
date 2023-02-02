output "eks_cluster_id" {
    value = aws_eks_cluster.cluster.id
}

output "eks_cluster_name" {
    value = aws_eks_cluster.cluster.name
}

output "eks_oidc_arn" {
    value = aws_iam_openid_connect_provider.eks.arn
}

output "eks_oidc_url" {
    value = aws_iam_openid_connect_provider.eks.url
}

output "eks_endpoint" {
    value = aws_eks_cluster.cluster.endpoint
}

output "eks_certificate_authority" {
    value = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "eks_cluster_iam_role_name" {
    value = aws_iam_role.cluster.name
}

output "eks_node_iam_role_name" {
    value = aws_iam_role.nodes.name
}

output "eks_node_iam_role_id" {
    value = aws_iam_role.nodes.id
}