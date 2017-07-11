resource "null_resource" "create_logging_export" {
  provisioner "local-exec" {
    command = "gcloud beta logging sinks create splunk pubsub.googleapis.com/projects/${var.project_name}/topics/${google_pubsub_topic.splunk.name} --log-filter='resource.type=\"container\" labels.\"container.googleapis.com/namespace_name\"!=\"kube-system\"'"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "gcloud beta logging sinks delete splunk"
  }
}
