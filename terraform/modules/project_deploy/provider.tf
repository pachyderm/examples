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

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.25.0"
    }

  }
}
provider "kubernetes" {
  host                   = module.pach_eks.eks_endpoint
  cluster_ca_certificate = base64decode(module.pach_eks.eks_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.pach_eks.eks_cluster_name]
    command     = "aws"
  }
}

#kubectl provider needed for karpenter
provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.pach_eks.eks_endpoint
  cluster_ca_certificate = base64decode(module.pach_eks.eks_certificate_authority)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.pach_eks.eks_cluster_name]
  }
}

provider "aws" {
  region              = var.aws_region
  shared_config_files = ["~/.aws/credentials"]
  profile             = var.aws_profile
}

provider "helm" {
  kubernetes {
    host                   = module.pach_eks.eks_endpoint
    cluster_ca_certificate = base64decode(module.pach_eks.eks_certificate_authority)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.pach_eks.eks_cluster_name]
      command     = "aws"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}