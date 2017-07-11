variable "aws_region" {}
variable "app_name" {}
variable "vpc_id" {}
variable "vpc_public_subnet_ids" {
  type = "list"
}
variable "instance_ami_id" {}
variable "instance_type" {}
variable "instance_key_name" {}
variable "instance_user_data" {}
variable "asg_min" {
  default = 1
}
variable "asg_max" {
  default = 1
}
variable "asg_desired" {
  default = 1
}
variable "sg_allow_ssh" {}
variable "sg_allow_http_s" {}

output "sg_instances" {
  value = "${aws_security_group.app_instances.id}"
}
output "elb_dns_name" {
  value = "${aws_elb.app.dns_name}"
}
output "asg_name" {
  value = "${aws_autoscaling_group.app.name}"
}
output "iam_role_arn" {
  value = "${aws_iam_role.app.arn}"
}
