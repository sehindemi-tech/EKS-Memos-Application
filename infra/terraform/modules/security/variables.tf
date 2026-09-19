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

variable "vpc_id" {
  description = "ID of the VPC everything in this project gets deployed into"
  type        = string

  validation {
    condition     = can(regex("^vpc-[0-9a-f]{8,17}$", var.vpc_id))
    error_message = "vpc_id must be a valid VPC ID in the form vpc-xxxxxxxx or vpc-xxxxxxxxxxxxxxxxx."
  }
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block, e.g. 10.0.0.0/16."
  }
}


variable "vpc_ingress_interface_endpoint_sg" {
  description = "Ingress rule for the VPC interface endpoints' security group"

  type = object({
    ingress_description = string
    ip_protocol         = string
    from_port           = number
    to_port             = number
  })

  validation {
    condition     = contains(["tcp", "udp", "icmp", "-1"], var.vpc_ingress_interface_endpoint_sg.ip_protocol)
    error_message = "ip_protocol must be one of: tcp, udp, icmp, or -1 (all protocols)."
  }

  validation {
    condition = (
      var.vpc_ingress_interface_endpoint_sg.from_port >= 0 &&
      var.vpc_ingress_interface_endpoint_sg.from_port <= 65535 &&
      var.vpc_ingress_interface_endpoint_sg.to_port >= 0 &&
      var.vpc_ingress_interface_endpoint_sg.to_port <= 65535
    )
    error_message = "from_port and to_port must each be between 0 and 65535."
  }

  validation {
    condition     = var.vpc_ingress_interface_endpoint_sg.from_port <= var.vpc_ingress_interface_endpoint_sg.to_port
    error_message = "from_port must be less than or equal to to_port."
  }
}

variable "vpc_egress_interface_endpoint_sg" {
  description = "Egress rule for the VPC interface endpoints' security group"

  type = object({
    egress_description = string
    ip_protocol        = string
    cidr_ipv4          = string
  })

  validation {
    condition     = contains(["tcp", "udp", "icmp", "-1"], var.vpc_egress_interface_endpoint_sg.ip_protocol)
    error_message = "ip_protocol must be one of: tcp, udp, icmp, or -1 (all protocols)."
  }

  validation {
    condition     = can(cidrhost(var.vpc_egress_interface_endpoint_sg.cidr_ipv4, 0))
    error_message = "cidr_ipv4 must be a valid IPv4 CIDR block, e.g. 10.0.0.0/16 or 0.0.0.0/0."
  }
}

variable "kms_key" {
  description = "KMS key config used to encrypt project resources (EKS secrets, RDS, etc.)"

  type = object({
    description             = string
    enable_key_rotation     = bool
    deletion_window_in_days = number
    alias_name              = string
  })

  validation {
    condition     = var.kms_key.deletion_window_in_days >= 7 && var.kms_key.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30, per AWS KMS's allowed range."
  }

  validation {
    condition     = can(regex("^alias/[a-zA-Z0-9/_-]+$", var.kms_key.alias_name))
    error_message = "alias_name must start with 'alias/' followed by alphanumeric characters, underscores, hyphens, or additional slashes."
  }

  validation {
    condition     = length(var.kms_key.description) <= 8192
    error_message = "description must be 8192 characters or fewer, per AWS KMS's limit."
  }
}


variable "bootstrap_role_arns" {
  description = "IAM role ARNs carried over from the bootstrap stack (e.g. Terraform plan/apply/destroy roles)"
  type        = list(string)

  validation {
    condition     = length(var.bootstrap_role_arns) > 0
    error_message = "bootstrap_role_arns must contain at least one role ARN."
  }

  validation {
    condition     = alltrue([for arn in var.bootstrap_role_arns : can(regex("^arn:aws:iam::[0-9]{12}:role/", arn))])
    error_message = "Every entry in bootstrap_role_arns must be a valid IAM role ARN, e.g. arn:aws:iam::123456789012:role/terraform-plan"
  }
}

variable "rds_sg_ingress_from_eks" {
  description = "Ingress rule that lets the EKS cluster reach RDS on the database port"

  type = object({
    ingress_description = string
    ip_protocol         = string
    from_port           = number
    to_port             = number
  })

  validation {
    condition     = var.rds_sg_ingress_from_eks.ip_protocol == "tcp"
    error_message = "ip_protocol must be tcp for RDS ingress (Postgres/MySQL/etc. run over TCP, not UDP)."
  }

  validation {
    condition     = var.rds_sg_ingress_from_eks.from_port == var.rds_sg_ingress_from_eks.to_port
    error_message = "from_port and to_port should match for a single database port rule (e.g. both 5432 for Postgres), not a range."
  }

  validation {
    condition     = var.rds_sg_ingress_from_eks.from_port > 0 && var.rds_sg_ingress_from_eks.from_port <= 65535
    error_message = "from_port must be between 1 and 65535."
  }
}

variable "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  type        = string

  validation {
    condition     = can(regex("^sg-[0-9a-f]{8,17}$", var.eks_cluster_security_group_id))
    error_message = "eks_cluster_security_group_id must be a valid security group ID in the form sg-xxxxxxxx or sg-xxxxxxxxxxxxxxxxx."
  }
}

