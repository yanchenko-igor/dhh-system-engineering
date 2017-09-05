module "ssh_bastion" {
  source                  = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/ssh_bastion"
  vpc_id                  = "${module.vpc1.vpc_id}"
  instance_ami_id         = "${data.aws_ami.ubuntu_xenial_ami.id}"
  instance_key_name       = "default-key"
  allowed_ssh_cidr_blocks = ["${var.office_ips}"]
  route53_zone_id         = "${aws_route53_zone.external_zone.id}"
  vpc_public_subnet_ids   = ["${module.vpc1.vpc_public_subnet_ids}"]
}
