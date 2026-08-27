variable "s3_buckets" {
  description = "S3 Bucket settings"

  type = object({
    bucket_settings = map(object({
      name          = string
      force_destroy = optional(bool, false)
      description   = optional(string)
      versioning    = optional(bool, true)
      sse_algorithm = optional(string, "AES256")
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

variable "ecr_settings" {
  description = "The ECR repository for memo app"
  type = object({
    image_tag_mutability = optional(string, "IMMUTABLE")
    force_delete         = optional(bool, true)

    image_scanning_configuration = optional(object({
      scan_on_push = optional(bool, true)
    }), {})

    encryption_configuration = optional(object({
      encryption_type = optional(string, "AES256")
    }), {})

  })

}

variable "iam_roles" {
  description = "IAM role variables for EKS GitHub Pipeline"
  type = map(object({
    description = optional(string, "")
    sub_value   = string
  }))
}
