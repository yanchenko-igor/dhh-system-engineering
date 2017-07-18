# SSH bastion

Creates and autoscaling group, security groups, IAM policy, EIP and user-data to automatically assign the EIP. This ensure a SSH bastion is always present and has a fixed EIP.

## Example

```hcl
module "ssh_bastion" {
  source                = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/ssh_bastion"
  vpc_id                = "${module.vpc1.vpc_id}"
  instance_ami_id       = "${data.aws_ami.ubuntu_xenial_ami.id}"
  instance_key_name     = "default-key"
  allow_ssh_sg_id       = "${aws_security_group.allow_ssh_from_office_ips.id}"
  route53_zone_id       = "${aws_route53_zone.vpc_internal_zone.id}"
  vpc_public_subnet_ids = ["${module.vpc1.vpc_public_subnet_ids}"]
}
```
