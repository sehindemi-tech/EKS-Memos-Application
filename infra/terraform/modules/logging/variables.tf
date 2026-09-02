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

variable "cloud_watch" {
  description = "CloudWatch log group settings"
  type = object({
    name              = string
    log_group_class   = string
    retention_in_days = number
  })
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}