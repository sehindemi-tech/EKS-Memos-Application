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
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
}


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