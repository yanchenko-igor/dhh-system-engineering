resource "google_container_cluster" "cluster1" {
  name               = "cluster1"
  zone               = "europe-west1-d"
  initial_node_count = 1

  additional_zones = [
    "europe-west1-b",
    "europe-west1-c",
  ]

  monitoring_service = "none"

  node_config {
    machine_type = "n1-highmem-4"

    oauth_scopes = [
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/servicecontrol"
    ]
  }
}

resource "null_resource" "enable_autoscaling" {
  provisioner "local-exec" {
    command = "gcloud container clusters update ${google_container_cluster.cluster1.name} --enable-autoscaling --min-nodes=3 --max-nodes=20 --project=${google_project.my-gcp-project.name}"
  }
}
