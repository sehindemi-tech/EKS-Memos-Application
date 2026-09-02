resource "aws_cloudwatch_log_group" "this" {
  name                        = var.cloud_watch.name
  skip_destroy                = false
  deletion_protection_enabled = false
  log_group_class             = var.cloud_watch.log_group_class
  retention_in_days           = var.cloud_watch.retention_in_days

}

