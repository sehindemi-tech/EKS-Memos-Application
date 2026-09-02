#####Route 53 Module
variable "route53_settings" {
  description = "Route 53 Zone for EKS Memo Application"
  type = object({
    name          = string
    force_destroy = optional(bool, false)
  })
}

#####Networking
variable "vpc_settings" {
  description = "VPC settings for the EKS Memo platform"
  type = object({
    cidr_block           = optional(string)
    enable_dns_hostnames = optional(bool)
    enable_dns_support   = optional(bool)
  })
}

variable "subnet_settings" {
  description = "Public & private VPC subnet definitions; is_public drives public IP assignment"

  type = map(object({
    availability_zone       = optional(string)
    cidr_block              = optional(string)
    map_public_ip_on_launch = optional(bool)
    is_public               = optional(bool)
  }))
}