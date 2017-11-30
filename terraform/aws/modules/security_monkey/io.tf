# The account ID from where security monkey will run.
variable "account_id" {}
# The role name that exists in the account above
variable "assume_role_name" {
  default = "SecurityMonkeyInstanceProfile"
}
variable "role_name" {
  default = "SecurityMonkey"
}
output "role_arn" {
  value = "${aws_iam_role.security_monkey.arn}"
}
