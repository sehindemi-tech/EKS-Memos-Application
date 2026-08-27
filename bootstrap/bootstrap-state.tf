resource "aws_s3_bucket" "states" {
  for_each = var.s3_buckets.bucket_settings

  bucket        = "${each.value.name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = each.value.force_destroy

  tags = {
    Description = each.value.description
    ManagedBy   = "Terraform"
    Project     = var.project_settings.project_name
  }
}

resource "aws_s3_bucket_versioning" "states_versioning" {
  for_each = var.s3_buckets.bucket_settings

  bucket = aws_s3_bucket.states[each.key].id

  versioning_configuration {
    status = each.value.versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "states_blocking" {
  for_each = aws_s3_bucket.states

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "state_sse" {
  for_each = var.s3_buckets.bucket_settings

  bucket = aws_s3_bucket.states[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = each.value.sse_algorithm
    }
  }
}