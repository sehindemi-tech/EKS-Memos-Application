terraform {
  required_version = "1.15.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.62.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

provider "tls" {

}