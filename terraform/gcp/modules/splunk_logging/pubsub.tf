resource "google_pubsub_topic" "splunk" {
  name = "splunk"
}

resource "google_pubsub_subscription" "splunk" {
  depends_on           = [ "google_pubsub_topic.splunk" ]
  name                 = "splunk"
  topic                = "splunk"
  ack_deadline_seconds = "${var.pub_sub_ack_deadline}"
}
