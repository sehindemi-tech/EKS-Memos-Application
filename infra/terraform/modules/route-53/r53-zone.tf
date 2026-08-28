resource "aws_route53_zone" "this" {
  name          = var.route53_settings.name
  force_destroy = var.route53_settings.force_destroy
}

