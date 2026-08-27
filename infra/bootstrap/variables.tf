variable "s3_buckets" {
  description = "S3 Bucket settings"
  type = object({
    bucket_settings = map(object({
      name          = string
      force_destroy = optional(bool, false)
      description   = optional(string)
    }))
  })
}

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