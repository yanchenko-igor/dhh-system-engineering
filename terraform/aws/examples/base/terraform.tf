terraform {
  required_version = ">= 0.9.11"

  # Uncomment lines below after initial apply
  # backend "s3" {
  #   bucket = "tf-state-xxxxxx"
  #   key    = "terraform.tfstate"
  #   region = "eu-west-1"
  # }
}

resource "random_id" "tf_state_bucket_suffix" {
  byte_length = 5
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "tf-state-${random_id.tf_state_bucket_suffix.dec}"
  region = "${var.aws_region}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

data "terraform_remote_state" "remote_state" {
  depends_on = ["aws_s3_bucket.terraform_state"]
  backend    = "s3"

  config {
    bucket = "${aws_s3_bucket.terraform_state.bucket}"
    key    = "terraform.tfstate"
    region = "${aws_s3_bucket.terraform_state.region}"
  }
}
