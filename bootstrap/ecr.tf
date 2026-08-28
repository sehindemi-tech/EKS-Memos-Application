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


resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = data.aws_ecr_lifecycle_policy_document.this.json
}

data "aws_ecr_lifecycle_policy_document" "this" {
  rule {
    priority    = 1
    description = "Expire untagged images older than 5 days"

    selection {
      tag_status   = "untagged"
      count_type   = "sinceImagePushed"
      count_unit   = "days"
      count_number = 7
    }

    action {
      type = "expire"
    }
  }

  rule {
    priority    = 2
    description = "Keep last 10 tagged images"

    selection {
      tag_status       = "tagged"
      tag_pattern_list = ["*"]
      count_type       = "imageCountMoreThan"
      count_number     = 10
    }

    action {
      type = "expire"
    }
  }
}