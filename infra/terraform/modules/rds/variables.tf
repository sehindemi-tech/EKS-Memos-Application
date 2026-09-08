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


variable "private_subnet_ids" {
  description = "Private subnet IDs for the EKS cluster and associated resources"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnet IDs are required for Multi-AZ RDS/EKS placement."
  }
}

variable "kms_key_id" {
  description = "KMS key for encrypting the RDS instance"
  type        = string
}
variable "vpc_security_group_ids" {
  description = "VPC security group IDs for the RDS instance"
  type        = list(string)
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
}