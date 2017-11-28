# The account ID from where security monkey will run.
variable "account_id" {}
# The role name that exists in the account above
variable "assume_role_name" {}
variable "role_name" {
  default = "security_monkey"
}
output "role_arn" {
  value = "${aws_iam_role.security_monkey.arn}"
}
