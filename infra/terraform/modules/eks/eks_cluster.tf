###trivy:ignore:AWS-0041 Access from person IP address
###trivy:ignore:AWS-0040 Public cluster access is enabled to allow access to cluster
resource "aws_eks_cluster" "this" {
  name                          = "${var.project_settings.project_name}-cluster"
  role_arn                      = aws_iam_role.this.arn
  version                       = var.eks_cluster_settings.version
  deletion_protection           = var.eks_cluster_settings.deletion_protection
  enabled_cluster_log_types     = var.eks_cluster_settings.enabled_cluster_log_type
  bootstrap_self_managed_addons = var.eks_cluster_settings.bootstrap_self_managed_addons

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = var.eks_cluster_settings.endpoint_public_access
    endpoint_private_access = var.eks_cluster_settings.endpoint_private_access
    public_access_cidrs     = var.eks_cluster_settings.public_access_cidrs
  }

  encryption_config {
    provider {
      key_arn = var.eks_cluster_kms_key
    }
    resources = ["secrets"]
  }

  access_config {
    authentication_mode                         = var.eks_cluster_settings.access_config.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.eks_cluster_settings.access_config.bootstrap_cluster_creator_admin_permissions

  }

  depends_on = [
    aws_iam_role.this,
    aws_iam_role_policy_attachment.this
  ]
}

