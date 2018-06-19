variable "cluster_name" {}
variable "cluster_ca_data" {}
variable "cluster_endpoint" {}
variable "master_sg_id" {}

variable "node_key_name" {
  default = "default"
}

variable "kubeconfig_path" {}

variable "node_instance_type" {
  default = "t2.medium"
}

variable "cluster_max_pods" {
  default = 100
}

variable "node_count" {
  default = 1
}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "extra_security_groups" {
  type    = "list"
  default = []
}

output "cluster_name" {
  value = "${var.cluster_name}"
}

output "autoscaling_group_arn" {
  value = "${aws_autoscaling_group.node.arn}"
}

output "iam_role_arn" {
  value = "${aws_iam_role.node.arn}"
}

output "sg_id" {
  value = "${aws_security_group.node.id}"
}
