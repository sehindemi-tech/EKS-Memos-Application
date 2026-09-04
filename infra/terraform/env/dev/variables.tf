##### Project Settings
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

#####Route 53 Module
variable "route53_settings" {
  description = "Route 53 Zone for EKS Memo Application"
  type = object({
    name          = string
    force_destroy = optional(bool, false)
  })
}

#####Networking
variable "vpc_settings" {
  description = "VPC settings for the EKS Memo platform"
  type = object({
    cidr_block           = optional(string)
    enable_dns_hostnames = optional(bool)
    enable_dns_support   = optional(bool)
  })
}

variable "subnet_settings" {
  description = "Public & private VPC subnet definitions; is_public drives public IP assignment"

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

variable "gateway_endpoint_settings" {
  description = "AWS service names for Gateway VPC endpoints (S3, DynamoDB)"
  type        = set(string)
}

variable "interface_endpoint_settings" {
  description = "AWS service names for Interface VPC endpoints"
  type        = set(string)
}


################Security Module
### VPC Endpoint Security Groups
variable "vpc_ingress_interface_endpoint_sg" {
  description = "VPC endpoint Security group for EKS memo application"
  type = object({
    ingress_description = string
    ip_protocol         = string
    from_port           = number
    to_port             = number
  })
}

variable "vpc_egress_interface_endpoint_sg" {
  description = "VPC endpoint Security group for EKS memo application"
  type = object({
    egress_description = string
    ip_protocol        = string
    cidr_ipv4          = string
  })
}

variable "kms_key" {
  description = "KMS key for the EKS memo project"
  type = object({
    description             = string
    enable_key_rotation     = bool
    deletion_window_in_days = number
    alias_name              = string
  })
}

variable "bootstrap_role_arns" {
  description = "IAM roles ARN from bootstrap"
  type        = list(string)
}

###logging
### CloudWatch Log Group for VPC Flow Logs
variable "cloud_watch" {
  description = "CloudWatch log group settings"
  type = object({
    name              = string
    log_group_class   = string
    retention_in_days = number
  })
}

#####EKS
variable "eks_cluster_settings" {
  description = "EKS cluster settings for the EKS memo Application"
  type = object({
    version                       = string
    deletion_protection           = bool
    enabled_cluster_log_type      = list(string)
    bootstrap_self_managed_addons = bool
    endpoint_public_access        = bool
    endpoint_private_access       = bool
    public_access_cidrs           = list(string)
    access_config = object({
      authentication_mode                         = string
      bootstrap_cluster_creator_admin_permissions = bool
    })
  })
}

variable "eks_node_managed_policy_arns" {
  description = "Managed IAM policy ARNs to attach to the EKS node group role"
  type        = list(string)
}

variable "eks_node_group_settings" {
  description = "EKS node group settings"
  type = object({
    instance_type = list(string)
    capacity_type = string
    ami_type      = string
    disk_size     = number

    scaling_config = object({
      min_size     = number
      max_size     = number
      desired_size = number
    })

    update_config = object({
      max_unavailable = number
      update_strategy = string
    })
  })
}