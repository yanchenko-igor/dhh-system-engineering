resource "random_id" "tf_state_bucket_suffix" {
  byte_length = 5
}

terraform {
  required_version = ">= 0.9.3"

  backend "gcs" {
    bucket  = "tf-state-${random_id.tf_state_bucket_suffix.dec}"
    path    = "env1/terraform.tfstate"
    project = "my-gcp-project"
  }
}

resource "google_storage_bucket" "tf_state" {
  name     = "tf-state-${random_id.tf_state_bucket_suffix.dec}"
  location = "EU"
}
