// Add GoogleApps as SAML IdP
resource "aws_iam_saml_provider" "sso-account_gapps" {
  name = "GoogleApps"
  saml_metadata_document = "${file("saml-metadata/GoogleIDPMetada-DOMAIN.xml")}"
  provider = "aws.sso-account"
}

output "sso-account_saml_provider_arn" {
  value = "${aws_iam_saml_provider.sso-account_gapps.arn}"
}

data "aws_iam_policy_document" "sso-account_gapps_crossaccount_assume" {
  statement {
    sid = "GoogleApps"
    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type = "Federated"
      identifiers = ["${aws_iam_saml_provider.sso-account_gapps.arn}"]
    }

    condition {
      test = "StringEquals"
      variable = "SAML:aud"
      values = ["https://signin.aws.amazon.com/saml"]
    }
  }

  statement {
    sid = "company"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${var.sso-account}:root"]
    }
  }


}
