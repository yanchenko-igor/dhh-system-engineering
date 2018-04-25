variable "idp_data_file_path" {}

variable "role_max_session_duration" {
  default = 43200
}

output "saml_provider_arn" {
  value = "${aws_iam_saml_provider.google.arn}"
}

output "sso_administrator_role_arn" {
  value = "${aws_iam_role.sso_administrator.arn}"
}

output "sso_readonly_role_arn" {
  value = "${aws_iam_role.sso_readonly.arn}"
}

output "sso_ec2fullaccess_role_arn" {
  value = "${aws_iam_role.sso_ec2fullaccess.arn}"
}

output "sso_sysadmin_role_arn" {
  value = "${aws_iam_role.sso_sysadmin.arn}"
}
