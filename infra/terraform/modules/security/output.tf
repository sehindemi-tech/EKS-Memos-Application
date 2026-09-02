output "interface_endpoint_sg" {
  description = "interface endpoint security group id"
  value       = aws_security_group.vpc_interface_endpoints.id
}
