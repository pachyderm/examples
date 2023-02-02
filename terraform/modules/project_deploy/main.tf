# A complete pachyderm deployment on AWS with Karpenter, Cloudflare, and Pachyderm Notebooks

module "pach_vpc" {
  source = "../aws_infra/vpc"

  project_name = var.name
  region       = var.aws_region
  admin_user   = var.admin_user
  vpc_cidr_block = var.vpc_cidr_block
  subnet_cidr_blocks = var.subnet_cidr_blocks
  private_destination_cidr_block = var.private_destination_cidr_block 
  public_destination_cidr_block = var.public_destination_cidr_block

  cluster_iam_role_name = module.pach_eks.eks_cluster_iam_role_name
}

module "pach_rds" {
  source = "../aws_infra/rds"

  project_name      = var.name
  admin_user        = var.admin_user
  db_version        = var.db_version
  db_instance_class = var.db_instance_class
  db_username       = var.db_username
  db_password       = var.db_password
  db_auth_type      = var.db_auth_type
  db_iops           = var.db_iops
  db_storage        = var.db_storage
  db_max_storage    = var.db_max_storage
  sg_id             = module.pach_vpc.sg_id
  public_subnet_ids = [module.pach_vpc.public_subnet_1_id, module.pach_vpc.public_subnet_2_id]
  nat_gateway_id    = module.pach_vpc.nat_gateway_id
  private_route_id  = module.pach_vpc.private_route_id
  public_route_id   = module.pach_vpc.public_route_id
  rta_id_list       = [module.pach_vpc.public_rta_1_id, module.pach_vpc.public_rta_2_id, module.pach_vpc.private_rta_1_id, module.pach_vpc.private_rta_2_id]
}

module "pach_eks" {
  source = "../aws_infra/eks"

  project_name = var.name
  region = var.aws_region
  aws_profile = var.aws_profile
  cluster_version = var.cluster_version
  admin_user   = var.admin_user
  ami_type = var.ami_type
  lt_ebs_optimized = var.lt_ebs_optimized
  lt_block_ebs_iops = var.lt_block_ebs_iops
  lt_block_ebs_size = var.lt_block_ebs_size
  lt_block_ebs_type = var.lt_block_ebs_type
  lt_block_ebs_throughput = var.lt_block_ebs_throughput
  sg_id        = module.pach_vpc.sg_id
  subnet_ids   = [module.pach_vpc.private_subnet_1_id, module.pach_vpc.private_subnet_2_id, module.pach_vpc.public_subnet_1_id, module.pach_vpc.public_subnet_2_id]
}

module "pach_s3" {
  source = "../aws_infra/s3"

  project_name = var.name
  admin_user   = var.admin_user

  eks_oidc_arn = module.pach_eks.eks_oidc_arn
  eks_oidc_url = module.pach_eks.eks_oidc_url
}

module "pach_k8s" {
  source = "../aws_infra/k8s"

  region       = var.aws_region
  project_name = var.name
  admin_user   = var.admin_user
  cluster_name = module.pach_eks.eks_cluster_name
  namespace    = var.namespace

  db_password                 = var.db_password
  console_oauth_client_secret = var.console_oauth_client_secret
  enterprise_license_key      = var.enterprise_license_key
  root_token                  = var.root_token
  cluster_deployment_id       = var.cluster_deployment_id
  enterprise_secret           = var.enterprise_secret
  oauth_client_secret         = var.oauth_client_secret

  dns_name = var.dns_name

  okta_oidc_issuer        = var.okta_oidc_issuer
  okta_oidc_client_id     = var.okta_oidc_client_id
  okta_oidc_client_secret = var.okta_oidc_client_secret

  github_oidc_client_id     = var.github_oidc_client_id
  github_oidc_client_secret = var.github_oidc_client_secret
}

module "pach_karpenter" {
  source = "../karpenter"

  count = var.enable_karpenter ? 1 : 0


  aws_profile                      = var.aws_profile
  region                           = var.aws_region
  project_name                     = var.name
  admin_user                       = var.admin_user
  karpenter_service_account_create = var.karpenter_service_account_create
  karpenter_service_account_name   = var.karpenter_service_account_name

  sg_id      = module.pach_vpc.sg_id
  subnet_ids = [module.pach_vpc.private_subnet_1_id, module.pach_vpc.private_subnet_2_id, module.pach_vpc.public_subnet_1_id, module.pach_vpc.public_subnet_2_id]

  cluster_name       = module.pach_eks.eks_cluster_name
  cluster_endpoint   = module.pach_eks.eks_endpoint
  node_iam_role_name = module.pach_eks.eks_node_iam_role_name
  node_iam_role_id   = module.pach_eks.eks_node_iam_role_id
  eks_oidc_arn       = module.pach_eks.eks_oidc_arn
  eks_oidc_url       = module.pach_eks.eks_oidc_url

  lt_ebs_optimized        = var.lt_ebs_optimized
  lt_block_ebs_iops       = var.lt_block_ebs_iops
  lt_block_ebs_throughput = var.lt_block_ebs_throughput
  lt_block_ebs_size       = var.lt_block_ebs_size
  lt_block_ebs_type       = var.lt_block_ebs_type

  depends_on = [
    module.pach_k8s
  ]
}

module "pach_pachyderm" {
  source = "../pachyderm"

  project_name                = var.name
  pach_version                = var.pach_version
  namespace                   = var.namespace
  pachyderm_secrets_name      = module.pach_k8s.pachyderm_secrets_name
  db_username                 = var.db_username
  db_auth_type                = var.db_auth_type
  db_host                     = module.pach_rds.postgres_address
  loki_storage_size           = var.loki_storage_size
  loki_storage_class          = var.loki_storage_class
  log_level                   = var.log_level
  loki_deploy                 = var.loki_deploy
  loki_logging                = var.loki_logging
  cluster_deployment_id       = var.cluster_deployment_id
  s3_role_arn                 = module.pach_s3.s3_role_arn
  s3_bucket_id                = module.pach_s3.s3_bucket_id
  region                      = var.aws_region
  console_image_tag           = var.console_image_tag
  pachd_image_repo            = var.pachd_image_repo
  pachd_image_tag             = var.pachd_image_tag
  worker_image_repo           = var.worker_image_repo
  worker_image_tag            = var.worker_image_tag
  pachd_cpu_request           = var.pachd_cpu_request
  pachd_memory_request        = var.pachd_memory_request
  etcd_storage_class          = var.etcd_storage_class
  etcd_storage_size           = var.etcd_storage_size
  etcd_cpu_request            = var.etcd_cpu_request
  etcd_memory_request         = var.etcd_memory_request
  pgbouncer_max_connections   = var.pgbouncer_max_connections
  pgbouncer_default_pool_size = var.pgbouncer_default_pool_size
  dns_name                    = var.dns_name
  admin_user                  = var.admin_user

  depends_on = [
    module.pach_eks,
  ]
}

module "pach_cloudflare" {
  source = "../cloudflare"

  count = var.enable_cloudflare ? 1 : 0

  namespace            = var.namespace
  project_name         = var.name
  dns_name             = var.dns_name
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id

  depends_on = [
    module.pach_eks,
    module.pach_k8s,
    module.pach_pachyderm
  ]
}

module "pach_notebooks" {
  source = "../jh-notebooks"

  count = var.enable_notebooks ? 1 : 0

  project_name              = var.name
  jupyter_version           = var.jupyter_version
  notebooks_namespace       = var.notebooks_namespace
  okta_oidc_issuer          = var.okta_oidc_issuer
  okta_oidc_client_id       = var.okta_oidc_client_id
  okta_oidc_client_secret   = var.okta_oidc_client_secret
  github_oidc_client_id     = var.github_oidc_client_id
  github_oidc_client_secret = var.github_oidc_client_secret
  aws_profile               = var.aws_profile
  notebook_dns_name         = var.notebook_dns_name
  admin_user                = var.admin_user
  notebooks_user_version    = var.notebooks_user_version
  mount_server_image        = var.mount_server_image
  namespace                 = var.namespace
  cloudflare_api_token      = var.cloudflare_api_token
  cloudflare_zone_id        = var.cloudflare_zone_id
  dns_name                  = var.dns_name

  depends_on = [
    module.pach_eks,
    module.pach_k8s,
    module.pach_pachyderm
  ]
}
