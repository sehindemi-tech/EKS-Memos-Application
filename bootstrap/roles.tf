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

