variable "route53_settings" {
  description = "Route 53 hosted zone the EKS Memo app's DNS records get created in"

  type = object({
    name          = string
    force_destroy = optional(bool, false)
  })
}