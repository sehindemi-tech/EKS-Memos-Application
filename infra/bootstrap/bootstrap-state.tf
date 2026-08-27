resource "aws_s3_bucket" "bootstrap_state" {
  for_each      = var.s3_buckets.bucket_settings
  bucket        = "${var.project_settings.project_name}-${each.key}-${data.aws_caller_identity.current.account_id}"
  force_destroy = each.value.force_destroy

  tags = {
    Name        = "${var.project_settings.project_name}-${each.key}"
    Description = each.value.description
    ManagedBy   = "Terraform"
    Project     = var.project_settings.project_name
  }

}

