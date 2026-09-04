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

variable "subnet_ids" {
  description = "List of subnet EKS ENI will be in"
  type        = list(string)
}

variable "eks_cluster_kms_key" {
  description = "The ARN of the KMS key for the EKS cluster encryption"
  type        = string
}

variable "eks_node_managed_policy_arns" {
  description = "Managed IAM policy ARNs to attach to the EKS node group role"
  type        = set(string)
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