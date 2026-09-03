resource "aws_kms_key" "this" {
  description             = var.kms_key.description
  deletion_window_in_days = var.kms_key.deletion_window_in_days
  enable_key_rotation     = var.kms_key.enable_key_rotation
  policy                  = data.aws_iam_policy_document.eks_kms_key.json
  tags = {
    Name = "${var.project_settings.project_name}-kms"
  }
}

resource "aws_kms_alias" "this" {
  name          = var.kms_key.alias_name
  target_key_id = aws_kms_key.this.key_id
}


data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eks_kms_key" {
  statement {
    sid    = "EnableRootAccountAdmin"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowTerraformRoleKeyManagement"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.bootstrap_role_arns
    }
    actions = [
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowEKSServiceUseOfKey"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = ["*"]
  }
}
