output "interface_endpoint_sg" {
  description = "interface endpoint security group id"
  value       = aws_security_group.vpc_interface_endpoints.id
}

output "eks_cluster_kms_key" {
  description = "The ARN of the KMS key for the EKS cluster encryption"
  value       = aws_kms_key.this.arn
}

output "kms_key" {
  description = "The ARN of the KMS key for general use"
  value       = aws_kms_key.this.arn
}

output "rds_sg" {
  description = "The security group ID for the RDS instance"
  value       = [aws_security_group.rds_sg.id]
}