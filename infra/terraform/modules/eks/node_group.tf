resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_settings.project_name}-ng"
  subnet_ids      = var.private_subnet_ids
  node_role_arn   = aws_iam_role.eks_node_iam_role.arn
  instance_types  = var.eks_node_group_settings.instance_type
  capacity_type   = var.eks_node_group_settings.capacity_type
  disk_size       = var.eks_node_group_settings.disk_size
  ami_type        = var.eks_node_group_settings.ami_type

  scaling_config {
    min_size     = var.eks_node_group_settings.scaling_config.min_size
    max_size     = var.eks_node_group_settings.scaling_config.max_size
    desired_size = var.eks_node_group_settings.scaling_config.desired_size
  }

  update_config {
    max_unavailable = var.eks_node_group_settings.update_config.max_unavailable
    update_strategy = var.eks_node_group_settings.update_config.update_strategy
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy_arns
  ]
}



variable "private_subnet_ids" {
  description = "Private Subnet ids "
  type        = list(string)
}


