# A unique name for this bastion
variable "name" {}

variable "vpc_id" {}
variable "route53_zone_id" {}
variable "instance_ami_id" {}
variable "instance_key_name" {}

variable "allowed_ssh_cidr_blocks" {
  type = "list"
}

variable "vpc_public_subnet_ids" {
  type = "list"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "extra_user_data" {
  default = ""
}

variable "instance_volume_size" {
  default = 32
}

output "bastion_sg_id" {
  value = "${aws_security_group.bastion.id}"
}

output "allow_ssh_from_bastion_sg_id" {
  value = "${aws_security_group.allow_ssh_from_bastion.id}"
}

output "bastion_aws_iam_role" {
  value = "${aws_iam_role.bastion_ec2_role.id}"
}
