variable "cluster_name" {}
variable "vpc_id" {}
variable "kubeconfig_dir" {}

variable "subnet_ids" {
  type = "list"
}

output "cluster_name" {
  value = "${var.cluster_name}"
}

output "cluster_endpoint" {
  value = "${aws_eks_cluster.cluster.endpoint}"
}

output "ca_data" {
  value = "${aws_eks_cluster.cluster.certificate_authority.0.data}"
}

output "sg_id" {
  value = "${aws_security_group.master.id}"
}

output "kubeconfig_path" {
  value = "${var.kubeconfig_dir}/${var.cluster_name}"
}
