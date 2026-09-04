resource "aws_iam_role" "eks_node_iam_role" {
  name               = "${var.project_settings.project_name}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
}

resource "aws_iam_role_policy_attachment" "node_policy_arns" {
  for_each = var.eks_node_managed_policy_arns

  role       = aws_iam_role.eks_node_iam_role.name
  policy_arn = each.value
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

