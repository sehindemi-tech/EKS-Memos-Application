terraform {
  required_version = "1.15.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.62.0"
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