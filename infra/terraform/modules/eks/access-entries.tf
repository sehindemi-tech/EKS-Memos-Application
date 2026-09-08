resource "aws_eks_access_entry" "this" {
  for_each = var.cluster_admins_principal_arns

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "this" {
  for_each = var.cluster_admins_principal_arns

  cluster_name  = aws_eks_cluster.this.id
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
}

