variable "splunk_hec_token" {}
variable "splunk_hec_url" {}

output "lambda_log_forwarder_arn" {
  value = "${aws_lambda_function.lambda_log_forwarder.arn}"
}
