variable "project_settings" {
  description = "Naming prefix and repo/org context used across the EKS Memo project's resources"

  type = object({
    aws_region   = optional(string, "eu-west-2")
    org          = optional(string, "sehindemi-tech")
    github_repo  = optional(string, "eks-memos-application")
    project_name = optional(string, "eks-memos-application")
  })

  default = {}

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.project_settings.aws_region))
    error_message = "aws_region must be a valid AWS region identifier, e.g. eu-west-2."
  }

  validation {
    condition     = length(var.project_settings.project_name) > 0 && length(var.project_settings.project_name) <= 63
    error_message = "project_name must be between 1 and 63 characters (used as a prefix in resource names, which have length limits)."
  }

  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$", var.project_settings.project_name))
    error_message = "project_name must be lowercase alphanumeric with hyphens only, and cannot start or end with a hyphen (used as a prefix for S3 buckets, IAM roles, and other AWS resources with naming restrictions)."
  }
}

variable "vpc_settings" {
  description = "Core VPC configuration"

  type = object({
    cidr_block           = optional(string)
    enable_dns_hostnames = optional(bool)
    enable_dns_support   = optional(bool)
    vpc_name             = optional(string)
  })

  validation {
    condition     = var.vpc_settings.cidr_block == null || can(cidrhost(var.vpc_settings.cidr_block, 0))
    error_message = "cidr_block must be a valid CIDR block, e.g. 10.0.0.0/16."
  }
}

variable "subnet_settings" {
  description = "Details about the Public & Private VPC subnets"

  type = map(object({
    availability_zone       = optional(string)
    cidr_block              = optional(string)
    map_public_ip_on_launch = optional(bool)
    is_public               = optional(bool)
  }))

  validation {
    condition = alltrue([
      for s in values(var.subnet_settings) : s.cidr_block == null || can(cidrhost(s.cidr_block, 0))
    ])
    error_message = "Every subnet's cidr_block must be a valid CIDR block, e.g. 10.0.1.0/24."
  }

  validation {
    condition     = length([for s in values(var.subnet_settings) : s if s.is_public == true]) > 0
    error_message = "At least one subnet must be marked is_public = true, the NAT gateway and any internet-facing load balancer need somewhere to live."
  }

  validation {
    condition     = length([for s in values(var.subnet_settings) : s if s.is_public != true]) >= 2
    error_message = "At least two private subnets are required for Multi-AZ EKS/RDS placement, ensuring high availability."
  }
}

variable "eip_domain" {
  description = "VPC Domain configuration for Elastic IP"
  type        = string

  validation {
    condition     = var.eip_domain == "vpc"
    error_message = "eip_domain must be 'vpc', 'standard' (EC2-Classic) isn't valid for a VPC-based NAT gateway."
  }
}

variable "gateway_endpoint_settings" {
  description = "AWS service names to create Gateway VPC endpoints for, e.g. s3, dynamodb"
  type        = set(string)

  validation {
    condition     = alltrue([for s in var.gateway_endpoint_settings : contains(["s3", "dynamodb"], s)])
    error_message = "gateway_endpoint_settings can only contain s3 and/or dynamodb, those are the only AWS services with gateway-type endpoints."
  }
}

variable "interface_endpoint_settings" {
  description = "AWS service names for Interface VPC endpoints"
  type        = set(string)

  validation {
    condition     = length(var.interface_endpoint_settings) > 0
    error_message = "interface_endpoint_settings can't be empty, pods in a private-subnet cluster need at least ECR and STS to pull images and authenticate."
  }
}

variable "interface_endpoint_sg_id" {
  description = "Interface endpoint Security Group ID"
  type        = string

  validation {
    condition     = can(regex("^sg-[0-9a-f]{8,17}$", var.interface_endpoint_sg_id))
    error_message = "interface_endpoint_sg_id must look like a real security group ID, e.g. sg-0123456789abcdef0."
  }
}