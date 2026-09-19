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
    error_message = "project_name must be between 1 and 63 characters (it's used as a prefix in resource names, which have length limits)."
  }

  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$", var.project_settings.project_name))
    error_message = "project_name must be lowercase alphanumeric with hyphens only, and cannot start or end with a hyphen (used as a prefix for S3 buckets, IAM roles, and other AWS resources with naming restrictions)."
  }
}

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

variable "vpc_id" {
  description = "ID of the VPC everything in this project gets deployed into"
  type        = string

  validation {
    condition     = can(regex("^vpc-[0-9a-f]{8,17}$", var.vpc_id))
    error_message = "vpc_id must look like a real VPC ID, e.g. vpc-0123456789abcdef0."
  }
}