variable "project_name" {}

variable "pub_sub_ack_deadline" {
  default = 10
}

output "splunk_service_account" {
  value = "${google_service_account.splunk.email}"
}
