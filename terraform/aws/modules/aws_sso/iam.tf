data "aws_iam_policy_document" "sso_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithSAML"]
    principals {
      type        = "Federated"
      identifiers = ["${aws_iam_saml_provider.google.arn}"]
    }
    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }
}

# AdministratorAccess
resource "aws_iam_role" "sso_administrator" {
  name               = "sso-admininstrator"
  path               = "/sso/"
  assume_role_policy = "${data.aws_iam_policy_document.sso_assume_role_policy.json}"
}
resource "aws_iam_role_policy_attachment" "sso_administrator" {
  role       = "${aws_iam_role.sso_administrator.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ReadOnlyAccess
resource "aws_iam_role" "sso_readonly" {
  name               = "sso-readonly"
  path               = "/sso/"
  assume_role_policy = "${data.aws_iam_policy_document.sso_assume_role_policy.json}"
}
resource "aws_iam_role_policy_attachment" "sso_readonly" {
  role       = "${aws_iam_role.sso_readonly.name}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# AmazonEC2FullAccess
resource "aws_iam_role" "sso_ec2fullaccess" {
  name               = "sso-ec2fullaccess"
  path               = "/sso/"
  assume_role_policy = "${data.aws_iam_policy_document.sso_assume_role_policy.json}"
}
resource "aws_iam_role_policy_attachment" "ec2fullaccess" {
  role       = "${aws_iam_role.sso_ec2fullaccess.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# SystemAdministrator
resource "aws_iam_role" "sso_sysadmin" {
  name               = "sso-sysadmin"
  path               = "/sso/"
  assume_role_policy = "${data.aws_iam_policy_document.sso_assume_role_policy.json}"
}
resource "aws_iam_role_policy_attachment" "sysadmin" {
  role       = "${aws_iam_role.sso_sysadmin.name}"
  policy_arn = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
}
