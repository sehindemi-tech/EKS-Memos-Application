resource "aws_ecr_repository" "this" {
  name                 = var.project_settings.project_name
  image_tag_mutability = var.ecr_settings.image_tag_mutability

  encryption_configuration {
    encryption_type = var.ecr_settings.encryption_configuration.encryption_type
  }

  image_scanning_configuration {
    scan_on_push = var.ecr_settings.image_scanning_configuration.scan_on_push
  }

  force_delete = var.ecr_settings.force_delete
}


