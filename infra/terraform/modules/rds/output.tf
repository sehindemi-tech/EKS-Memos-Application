output "rds_secret_arn" {
  description = "RDS Secret ARN"
  value       = aws_db_instance.memo.master_user_secret[0].secret_arn
}