variable "vpc_settings" {
  description = "VPC settings for the EKS Memo platform"

  type = object({
    cidr_block           = optional(string)
    enable_dns_hostnames = optional(bool)
    enable_dns_support   = optional(bool)
    vpc_name             = optional(string)
  })
}

variable "subnet_settings" {
  description = "Details about the Public & Private vpc subnets"

  type = map(object({
    availability_zone       = optional(string)
    cidr_block              = optional(string)
    map_public_ip_on_launch = optional(bool)
    is_public               = optional(bool)
  }))
}

variable "eip_domain" {
  description = "VPC domain configuration for Elastic IP"
  type        = string
}