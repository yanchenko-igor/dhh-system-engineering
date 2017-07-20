# A unique name for resources
variable "name" {}
# The base URL of the ECR repository
variable "aws_ecr_repository_base" {}
# The name of the context/cluster/user in the kube_config file
variable "kube_config_name" {}

output "lambda_function_arn" {
  value = "${aws_lambda_function.kubernetes_deployer.arn}"
}
output "iam_role_name" {
  value = "${aws_iam_role.kubernetes_deployer.name}"
}
