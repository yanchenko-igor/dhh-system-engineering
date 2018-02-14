resource "aws_lambda_function" "kubernetes_deployer" {
  function_name = "kubernetes_deployer_${var.name}"
  filename      = "lambda_kubernetes_deployer.zip"
  role          = "${aws_iam_role.kubernetes_deployer.arn}"
  handler       = "patch_deployment.lambda_handler"
  runtime       = "python3.6"
  timeout       = "120"
  memory_size   = "128"
  description   = "A function to update a Kubernetes deployment with new image tag"

  environment {
    variables = {
      AWS_ECR_REPOSITORY_BASE = "${var.aws_ecr_repository_base}"
      KUBE_CONFIG_NAME        = "${var.kube_config_name}"
    }
  }
}

resource "aws_cloudwatch_log_group" "kubernetes_deployer" {
  name              = "/aws/lambda/${aws_lambda_function.kubernetes_deployer.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "kubernetes_deployer" {
  statement_id  = "kubernetes_deployer_${var.name}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.kubernetes_deployer.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.kubernetes_deployer.arn}"
}

resource "aws_cloudwatch_event_rule" "kubernetes_deployer" {
  name        = "kubernetes_deployer_${var.name}"
  description = "Captures the ECR PutImage API request for ${var.name} kubernetes deployer"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ecr"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventName": ["PutImage"],
    "eventSource": ["ecr.amazonaws.com"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "kubernetes_deployer" {
  rule = "${aws_cloudwatch_event_rule.kubernetes_deployer.name}"
  arn  = "${aws_lambda_function.kubernetes_deployer.arn}"
}
