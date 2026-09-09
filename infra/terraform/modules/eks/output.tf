output "eks_cluster_security_group_id" {
  description = "The security group ID of the EKS cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}


output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Cluster certificate authority data"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_name" {
  description = "Cluster name"
  value       = aws_eks_cluster.this.name
}