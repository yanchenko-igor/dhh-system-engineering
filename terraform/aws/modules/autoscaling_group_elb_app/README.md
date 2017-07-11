# autoscale group app with ELB

An example of an autoscaling group and ELB. Should be customised to suit.

## Example

```
module "asg_app_1" {
  source                = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/autoscaling_group_elb_app"
  aws_region            = "${var.aws_region}"
  app_name              = "app1"
  vpc_id                = "${module.vpc1.vpc_id}"
  instance_ami_id       = "${data.aws_ami.ubuntu_xenial_ami.id}"
  instance_key_name     = "default-key"
  instance_type         = "t2.small"
  instance_user_data    = ""
  sg_allow_ssh          = "${module.ssh_bastion.allow_ssh_from_bastion_sg_id}"
  sg_allow_http_s       = "${aws_security_group.allow_http_s_from_office_ips.id}"
  vpc_public_subnet_ids = ["${module.vpc1.vpc_public_subnet_ids}"]
}
```

## To do

- Add scaling policy example
