terraform {
  required_version = "1.15.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.62.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      Name        = "EKS-Plaatform-Project"
      ManagedBy   = "Terraform"
      Project     = "EKS-Platform"
      Environment = "Demi-SandBox"
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "eu-west-2"]
    }
  }
}