terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.16.0"
    }
  }
}
provider "kubernetes" {
  host                   = aws_eks_cluster.pachaform_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.pachaform_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.pachaform_cluster.name]
    command     = "aws"
  }
}

#kubectl provider needed for karpenter
provider "kubectl" {
  apply_retry_count      = 5
  host                   = aws_eks_cluster.pachaform_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.pachaform_cluster.certificate_authority[0].data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.pachaform_cluster.name]
  }
}

provider "aws" {
  region              = var.region
  shared_config_files = ["~/.aws/credentials"]
  profile             = var.aws_profile
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.pachaform_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.pachaform_cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.pachaform_cluster.name]
      command     = "aws"
    }
  }
}

provider "postgresql" {
  scheme    = "awspostgres"
  host      = aws_db_instance.pachaform_postgres.address
  username  = aws_db_instance.pachaform_postgres.username
  port      = aws_db_instance.pachaform_postgres.port
  password  = aws_db_instance.pachaform_postgres.password
  superuser = false

  expected_version = aws_db_instance.pachaform_postgres.engine_version
}