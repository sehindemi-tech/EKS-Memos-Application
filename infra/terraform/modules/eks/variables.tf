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

variable "subnet_ids" {
  description = "Subnets the EKS control plane's ENIs get placed in"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnets are required, EKS needs subnets in at least two AZs."
  }

  validation {
    condition     = alltrue([for id in var.subnet_ids : can(regex("^subnet-[0-9a-f]{8,17}$", id))])
    error_message = "Every entry must be a real subnet ID, e.g. subnet-0123456789abcdef0."
  }
}

variable "eks_cluster_kms_key" {
  description = "The ARN of the KMS key for the EKS cluster encryption"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:kms:", var.eks_cluster_kms_key))
    error_message = "eks_cluster_kms_key must be a full KMS key ARN, not just a key ID or alias."
  }
}

variable "eks_node_managed_policy_arns" {
  description = "Managed IAM policy ARNs to attach to the EKS node group role"
  type        = set(string)

  validation {
    condition     = alltrue([for arn in var.eks_node_managed_policy_arns : can(regex("^arn:aws:iam::(aws|[0-9]{12}):policy/", arn))])
    error_message = "Every entry must be a real IAM policy ARN."
  }
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

  validation {
    condition     = length(var.eks_node_group_settings.instance_type) > 0
    error_message = "instance_type can't be empty, at least one instance type is required."
  }

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.eks_node_group_settings.capacity_type)
    error_message = "capacity_type must be ON_DEMAND or SPOT."
  }

  validation {
    condition     = var.eks_node_group_settings.disk_size >= 20
    error_message = "disk_size must be at least 20 GiB, EKS's practical floor for the base AMI plus container images."
  }

  validation {
    condition = (
      var.eks_node_group_settings.scaling_config.min_size <= var.eks_node_group_settings.scaling_config.desired_size &&
      var.eks_node_group_settings.scaling_config.desired_size <= var.eks_node_group_settings.scaling_config.max_size
    )
    error_message = "scaling_config must satisfy min_size <= desired_size <= max_size."
  }

  validation {
    condition     = var.eks_node_group_settings.scaling_config.min_size >= 1
    error_message = "min_size must be at least 1, a node group can't scale to zero nodes."
  }

  validation {
    condition     = var.eks_node_group_settings.update_config.max_unavailable >= 1
    error_message = "max_unavailable must be at least 1, or a rolling update can never make progress."
  }

  validation {
    condition     = contains(["DEFAULT", "MINIMAL"], var.eks_node_group_settings.update_config.update_strategy)
    error_message = "update_strategy must be DEFAULT or MINIMAL."
  }
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

variable "hosted_zone_arn" {
  description = "Route 53 hosted zone ARN this project's DNS records live in"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:route53:::hostedzone/[A-Z0-9]+$", var.hosted_zone_arn))
    error_message = "hosted_zone_arn must be a real Route 53 hosted zone ARN, e.g. arn:aws:route53:::hostedzone/Z0123456789."
  }
}

variable "rds_secret_arn" {
  description = "Secrets Manager ARN for the RDS master credentials"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:secretsmanager:", var.rds_secret_arn))
    error_message = "rds_secret_arn must be a Secrets Manager ARN."
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

variable "kms_key" {
  description = "KMS key ARN used to encrypt the RDS instance"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:kms:", var.kms_key))
    error_message = "kms_key must be a full KMS key ARN, not just a key ID or alias."
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