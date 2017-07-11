resource "google_service_account" "splunk" {
  account_id   = "splunk"
  display_name = "splunk"
}

data "google_iam_policy" "splunk" {
  binding {
    role    = "roles/pubsub.viewer"
    members = [
      "serviceAccount:${google_service_account.splunk.email}",
    ]
  }

  binding {
    role    = "roles/pubsub.subscriber"
    members = [
      "serviceAccount:${google_service_account.splunk.email}",
    ]
  }
}

resource "null_resource" "create_service_account_key" {
  provisioner "local-exec" {
    command = "gcloud iam service-accounts keys create splunk_service_account_key.json --iam-account=${google_service_account.splunk.email}"
  }
}
