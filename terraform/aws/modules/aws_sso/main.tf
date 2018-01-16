resource "aws_iam_saml_provider" "google" {
  name                   = "google"
  saml_metadata_document = "${file(var.idp_data_file_path)}"
}
