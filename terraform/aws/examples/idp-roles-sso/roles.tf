
// Create roles to be assumed via GoogleApps
resource "aws_iam_role" "sso-account_administrator" {
  name = "Administrator"
  assume_role_policy = "${data.aws_iam_policy_document.sso-account_gapps_crossaccount_assume.json}"
  provider = "aws.sso-account"
}

resource "aws_iam_role_policy_attachment" "sso-account_administrator" {
  role = "${aws_iam_role.sso-account_administrator.name}"
  policy_arn = "${var.administrator_default_arn}"
  provider = "aws.sso-account"
}

resource "aws_iam_role" "sso-account_developer" {
  name = "Developer"
  assume_role_policy = "${data.aws_iam_policy_document.sso-account_gapps_crossaccount_assume.json}"
  provider = "aws.sso-account"
}

resource "aws_iam_role_policy_attachment" "sso-account_developer" {
  role = "${aws_iam_role.sso-account_developer.name}"
  policy_arn = "${var.developer_default_arn}"
  provider = "aws.sso-account"
}
