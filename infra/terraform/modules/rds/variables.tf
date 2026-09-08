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