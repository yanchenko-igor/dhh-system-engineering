provider "aws" {
  region              = "eu-west-1"
  alias               = "sso-account"
  profile             = "sso-account"
  allowed_account_ids = ["${var.sso-account}"]
}
