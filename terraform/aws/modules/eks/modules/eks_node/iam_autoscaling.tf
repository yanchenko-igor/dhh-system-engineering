resource "aws_iam_policy_attachment" "node_autoscaling" {
  name = "node_autoscaling"

  roles = [
    "${aws_iam_role.node.name}",
  ]

  policy_arn = "${aws_iam_policy.node_autoscaling.arn}"
}

resource "aws_iam_policy" "node_autoscaling" {
  name        = "node_autoscaling"
  description = "node_autoscaling"
  policy      = "${data.aws_iam_policy_document.node_autoscaling.json}"
}

data "aws_iam_policy_document" "node_autoscaling" {
  statement {
    sid    = "eksDemoNodeAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:GetAsgForInstance",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksDemoNodeOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/Name"
      values   = ["node"]
    }
  }
}
