# Lambda Splunk Forwarder

A lambda function, IAM policy and Cloudwatch log subscription to forward a Cloudwatch log group to a Splunk HTTP events collector.

More info here: http://dev.splunk.com/view/event-collector/SP-CAAAE6Y

## Example

```
data "aws_caller_identity" "current" {}

module "log_forwarder" {
  source                = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/lambda_splunk_forwarder"
  splunk_hec_token      = "xxxxxxxxxxxxxx"
  splunk_hec_url        = "https://my.splunk.host.com/services/collector"
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group_1" {
  name              = "/mylogs/log_group_1"
  retention_in_days = "7"
}

resource "aws_lambda_permission" "cloudwatch_log_group_1" {
  statement_id   = "cloudwatch_log_group_1"
  action         = "lambda:InvokeFunction"
  source_account = "${data.aws_caller_identity.current.account_id}"
  function_name  = "${module.log_forwarder.lambda_log_forwarder_arn}"
  principal      = "logs.eu-west-1.amazonaws.com"
  source_arn     = "${aws_cloudwatch_log_group.cloudwatch_log_group_1.arn}"
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_log_group_1" {
  depends_on      = [ "aws_lambda_permission.cloudwatch_log_group_1" ]
  name            = "cloudwatch_log_group_1_subscription_filter"
  destination_arn = "${module.log_forwarder.lambda_log_forwarder_arn}"
  filter_pattern  = ""
  log_group_name  = "${aws_cloudwatch_log_group.cloudwatch_log_group_1.name}"
}
```

## Notes

If your Splunk HEC endpoint filters by source IP address then you should run your Lambda function inside your VPC with a NAT gateway and fixed EIP.
