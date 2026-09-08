output "hosted_zone_arn" {
  description = "The ARN of the Route 53 hosted zone"
  value       = aws_route53_zone.this.arn
}