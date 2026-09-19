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
variable "private_subnet_ids" {
  description = "Private subnet IDs for the EKS cluster and associated resources"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnet IDs are required for Multi-AZ RDS/EKS placement."
  }

  validation {
    condition     = alltrue([for id in var.private_subnet_ids : can(regex("^subnet-[0-9a-f]{8,17}$", id))])
    error_message = "Every entry must be a real subnet ID, e.g. subnet-0123456789abcdef0."
  }
}

variable "kms_key_id" {
  description = "KMS key for encrypting the RDS instance"
  type        = string

  validation {
    condition     = can(regex("^(arn:aws:kms:|[0-9a-f]{8}-)", var.kms_key_id))
    error_message = "kms_key_id must be a KMS key ARN or key ID, not an alias,— RDS storage encryption doesn't accept aliases here."
  }
}
variable "vpc_security_group_ids" {
  description = "VPC security group IDs for the RDS instance"
  type        = list(string)

  validation {
    condition     = length(var.vpc_security_group_ids) > 0
    error_message = "vpc_security_group_ids can't be empty, RDS needs at least one security group."
  }

  validation {
    condition     = alltrue([for id in var.vpc_security_group_ids : can(regex("^sg-[0-9a-f]{8,17}$", id))])
    error_message = "Every entry must be a real security group ID, e.g. sg-0123456789abcdef0."
  }
}

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