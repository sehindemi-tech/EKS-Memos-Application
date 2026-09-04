output "vpc_id" {
  description = "The ID of the VPC for the EKS Memos Application"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC for the EKS Memos Application"
  value       = aws_vpc.this.cidr_block
}

output "subnet_ids" {
  description = "Subnet ID for both the public and private subnets"
  value       = concat(values(aws_subnet.private)[*].id, values(aws_subnet.public)[*].id)
}
output "private_subnet_ids" {
  description = "Private Subnet ID for EKS memo Application"
  value       = values(aws_subnet.private)[*].id
}