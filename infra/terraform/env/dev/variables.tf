##### Project Settings
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
    error_message = "aws_region must look like a real AWS region, e.g. eu-west-2."
  }

  validation {
    condition     = length(var.project_settings.project_name) > 0 && length(var.project_settings.project_name) <= 63
    error_message = "project_name must be 1-63 characters, it's used as a prefix for resources with their own length limits."
  }

  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$", var.project_settings.project_name))
    error_message = "project_name must be lowercase, alphanumeric and hyphens only, and can't start or end with a hyphen."
  }
}

#####Route 53 Module
variable "route53_settings" {
  description = "Route 53 hosted zone the EKS Memo app's DNS records get created in"

  type = object({
    name          = string
    force_destroy = optional(bool, false)
  })
}

#####Networking
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


################Security Module
### VPC Endpoint Security Groups
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



##############logging
### CloudWatch Log Group for VPC Flow Logs
variable "cloud_watch" {
  description = "CloudWatch log group settings"

  type = object({
    name              = string
    log_group_class   = string
    retention_in_days = number
  })

  validation {
    condition     = can(regex("^[a-zA-Z0-9_\\-/.#]{1,512}$", var.cloud_watch.name))
    error_message = "name must be 1-512 characters using only letters, numbers, and _-/.# — CloudWatch's allowed character set for log group names."
  }

  validation {
    condition     = contains(["STANDARD", "INFREQUENT_ACCESS"], var.cloud_watch.log_group_class)
    error_message = "log_group_class must be STANDARD or INFREQUENT_ACCESS."
  }

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, 0], var.cloud_watch.retention_in_days)
    error_message = "retention_in_days must be one of CloudWatch's fixed values (1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653) or 0 for never expire."
  }
}

##############EKS

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

  validation {
    condition     = can(regex("^1\\.[0-9]{2}$", var.eks_cluster_settings.version))
    error_message = "version must look like an EKS version number, e.g. 1.33."
  }

  validation {
    condition = alltrue([
      for t in var.eks_cluster_settings.enabled_cluster_log_type :
      contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], t)
    ])
    error_message = "enabled_cluster_log_type can only contain: api, audit, authenticator, controllerManager, scheduler."
  }

  validation {
    condition     = var.eks_cluster_settings.endpoint_public_access || var.eks_cluster_settings.endpoint_private_access
    error_message = "At least one of endpoint_public_access or endpoint_private_access must be true, or nothing can reach the cluster's API server at all."
  }

  validation {
    condition = alltrue([
      for c in var.eks_cluster_settings.public_access_cidrs : can(cidrhost(c, 0))
    ])
    error_message = "Every entry in public_access_cidrs must be a valid CIDR block, e.g. 94.0.92.6/32."
  }

  validation {
    condition     = !var.eks_cluster_settings.endpoint_public_access || length(var.eks_cluster_settings.public_access_cidrs) > 0
    error_message = "If endpoint_public_access is true, public_access_cidrs can't be empty, that would leave the public endpoint open to 0.0.0.0/0 by default."
  }

  validation {
    condition     = contains(["API", "API_AND_CONFIG_MAP", "CONFIG_MAP"], var.eks_cluster_settings.access_config.authentication_mode)
    error_message = "Authentication_mode must be API, API_AND_CONFIG_MAP, or CONFIG_MAP."
  }
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


variable "cluster_admins_principal_arns" {
  description = "IAM principal ARNs granted cluster-admin access to the EKS cluster"
  type        = map(string)

  validation {
    condition     = length(var.cluster_admins_principal_arns) > 0
    error_message = "cluster_admins_principal_arns can't be empty, at least one admin principal is needed to manage the cluster."
  }

  validation {
    condition     = alltrue([for arn in values(var.cluster_admins_principal_arns) : can(regex("^arn:aws:iam::[0-9]{12}:", arn))])
    error_message = "Every value must be a real IAM principal ARN (user or role)."
  }
}


variable "prometheus_basic_auth_secret_arn" {
  description = "Secrets Manager ARN for Prometheus's basic-auth htpasswd credential"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:secretsmanager:", var.prometheus_basic_auth_secret_arn))
    error_message = "prometheus_basic_auth_secret_arn must be a Secrets Manager ARN."
  }
}

variable "grafana_admin_credentials_secret_arn" {
  description = "Secrets Manager ARN for Grafana's admin username/password"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:secretsmanager:", var.grafana_admin_credentials_secret_arn))
    error_message = "grafana_admin_credentials_secret_arn must be a Secrets Manager ARN."
  }
}

###########RDS Module

variable "rds_instance_settings" {
  description = "RDS instance configuration"

  type = object({
    allocated_storage           = number
    max_allocated_storage       = number
    allow_major_version_upgrade = bool
    apply_immediately           = bool
    auto_minor_version_upgrade  = bool
    backup_retention_period     = number
    backup_window               = string
    db_name                     = string
    deletion_protection         = bool
    engine                      = string
    username                    = string
    engine_version              = string
    skip_final_snapshot         = bool
    instance_class              = string
    maintenance_window          = string
    manage_master_user_password = bool
    multi_az                    = bool
    publicly_accessible         = bool
    storage_encrypted           = bool
    storage_type                = string
  })

  validation {
    condition     = var.rds_instance_settings.storage_encrypted
    error_message = "storage_encrypted must be true, this database holds application data and should never be provisioned unencrypted."
  }

  validation {
    condition     = var.rds_instance_settings.publicly_accessible == false
    error_message = "publicly_accessible must be false, RDS should stay inside the VPC, reachable only from EKS."
  }

  validation {
    condition     = var.rds_instance_settings.allocated_storage >= 20
    error_message = "allocated_storage must be at least 20 GiB, that's RDS's practical floor for most engines."
  }

  validation {
    condition     = var.rds_instance_settings.max_allocated_storage >= var.rds_instance_settings.allocated_storage
    error_message = "max_allocated_storage must be greater than or equal to allocated_storage, or storage autoscaling can't do anything."
  }

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.rds_instance_settings.storage_type)
    error_message = "storage_type must be one of: gp2, gp3, io1, io2."
  }

  validation {
    condition     = var.rds_instance_settings.backup_retention_period >= 1 && var.rds_instance_settings.backup_retention_period <= 35
    error_message = "backup_retention_period must be between 1 and 35 days, 0 disables backups entirely, which isn't acceptable here."
  }

  validation {
    condition     = can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]-([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.rds_instance_settings.backup_window))
    error_message = "backup_window must be in HH:MM-HH:MM format (UTC), e.g. 03:00-04:00."
  }

  validation {
    condition     = can(regex("^[a-z]{3}:([0-1][0-9]|2[0-3]):[0-5][0-9]-[a-z]{3}:([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.rds_instance_settings.maintenance_window))
    error_message = "maintenance_window must be in ddd:HH:MM-ddd:HH:MM format (UTC), e.g. mon:04:00-mon:05:00."
  }

  validation {
    condition     = can(regex("^db\\.", var.rds_instance_settings.instance_class))
    error_message = "instance_class must be a real RDS instance class, e.g. db.t3.micro."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9_]*$", var.rds_instance_settings.db_name))
    error_message = "db_name must start with a letter and contain only lowercase letters, numbers, and underscores, Postgres identifier rules."
  }

  validation {
    condition     = length(var.rds_instance_settings.username) >= 1 && !contains(["rdsadmin", "admin"], lower(var.rds_instance_settings.username))
    error_message = "username can't be empty or a reserved name like 'rdsadmin'/'admin'."
  }
}


variable "argocd_config" {
  description = "Configuration for Argo CD Helm release"

  type = object({
    name             = string
    repository       = string
    chart            = string
    version          = string
    namespace        = string
    create_namespace = bool
  })

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+", var.argocd_config.version))
    error_message = "version must be a semantic version, e.g. 10.8.3."
  }
}