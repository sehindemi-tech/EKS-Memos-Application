variable "project_settings" {
  description = "The Default setting for our EKS Memo Project"

  type = object({
    aws_region   = optional(string, "eu-west-2")
    org          = optional(string, "sehindemi-tech")
    github_repo  = optional(string, "eks-memos-application")
    project_name = optional(string, "eks-memos-application")
  })

  default = {}
}

variable "vpc_settings" {
  description = "VPC settings for the EKS Memo platform"

  type = object({
    cidr_block           = optional(string)
    enable_dns_hostnames = optional(bool)
    enable_dns_support   = optional(bool)
    vpc_name             = optional(string)
  })
}

variable "subnet_settings" {
  description = "Details about the Public & Private vpc subnets"

  type = map(object({
    availability_zone       = optional(string)
    cidr_block              = optional(string)
    map_public_ip_on_launch = optional(bool)
    is_public               = optional(bool)
  }))
}

variable "eip_domain" {
  description = "VPC domain configuration for Elastic IP"
  type        = string
}

