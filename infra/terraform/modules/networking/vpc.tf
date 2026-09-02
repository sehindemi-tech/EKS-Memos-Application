resource "aws_vpc" "this" {
  cidr_block           = var.vpc_settings.cidr_block
  enable_dns_hostnames = var.vpc_settings.enable_dns_hostnames
  enable_dns_support   = var.vpc_settings.enable_dns_support
}

variable "vpc_settings" {
  description = "VPC settings for the EKS Memo platform"
  type = object({
    cidr_block           = optional(string)
    enable_dns_hostnames = optional(bool)
    enable_dns_support   = optional(bool)
  })
}