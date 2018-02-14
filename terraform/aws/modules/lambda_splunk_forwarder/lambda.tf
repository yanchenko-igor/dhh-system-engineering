resource "null_resource" "create_lambda_zip_file" {
  provisioner "local-exec" {
    command = "cd ${path.module}; rm -f *.zip; zip -q -r lambda_log_forwarder.zip lib index.js"
  }
}

resource "aws_lambda_function" "lambda_log_forwarder" {
  depends_on    = ["null_resource.create_lambda_zip_file"]
  filename      = "${path.module}/lambda_log_forwarder.zip"
  function_name = "log_forwarder"
  role          = "${aws_iam_role.lambda_log_forwarder.arn}"
  handler       = "index.handler"
  runtime       = "nodejs6.10"
  timeout       = "10"
  memory_size   = "128"
  description   = "A function to forward logs from AWS to a Splunk HEC"

  environment {
    variables = {
      SPLUNK_HEC_TOKEN = "${var.splunk_hec_token}"
      SPLUNK_HEC_URL   = "${var.splunk_hec_url}"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_forwarder" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_log_forwarder.function_name}"
  retention_in_days = 7
}
