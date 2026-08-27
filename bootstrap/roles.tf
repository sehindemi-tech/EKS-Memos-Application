resource "aws_iam_role" "this" {
  for_each = var.iam_roles

  name               = "${var.project_settings.project_name}-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.this[each.key].json
  description        = each.value.description
}

data "aws_iam_policy_document" "this" {
  for_each = var.iam_roles

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [each.value.sub_value]
    }
  }

}

resource "aws_iam_role_policy" "this" {
  for_each = var.iam_roles
  role     = aws_iam_role.this[each.key].id
  policy   = data.aws_iam_policy_document.role_policies[each.key].json
}
#trivy:ignore:AVD-AWS-0345 will clean actions later
data "aws_iam_policy_document" "role_policies" {
  for_each = var.iam_roles
  statement {
    effect = "Allow"
    actions = [
      "ec2:*",
      "eks:*",
      "iam:*",
      "kms:*",
      "rds:*",
      "s3:*",
      "logs:*",
      "ecr:*",
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }
}