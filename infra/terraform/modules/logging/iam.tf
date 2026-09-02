resource "aws_iam_role" "flow_logs_iam" {
  description        = "Flow logs IAM role"
  name               = "${var.project_settings.project_name}-flow_logs_iam"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_iam_policies.json
}

data "aws_iam_policy_document" "flow_logs_iam_policies" {
  statement {
    sid     = "IamFlowLogs"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "flow_logs_iam_policies_attachment" {
  role       = aws_iam_role.flow_logs_iam.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
