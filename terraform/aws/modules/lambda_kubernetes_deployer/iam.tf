resource "aws_iam_role" "kubernetes_deployer" {
  name               = "kubernetes_deployer_${var.name}"
  assume_role_policy = "${data.aws_iam_policy_document.kubernetes_deployer_assume_role_policy.json}"
}

resource "aws_iam_policy_attachment" "kubernetes_deployer" {
  name       = "kubernetes_deployer_${var.name}_attachment"
  roles      = ["${aws_iam_role.kubernetes_deployer.name}"]
  policy_arn = "${aws_iam_policy.kubernetes_deployer.arn}"
}

resource "aws_iam_policy" "kubernetes_deployer" {
  name        = "kubernetes_deployer_${var.name}"
  description = "Policy for ${aws_lambda_function.kubernetes_deployer.function_name} Lambda function"
  policy      = "${data.aws_iam_policy_document.kubernetes_deployer.json}"
}

data "aws_iam_policy_document" "kubernetes_deployer" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "kubernetes_deployer_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
