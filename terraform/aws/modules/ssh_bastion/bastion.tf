resource "aws_eip" "bastion_eip" {
  vpc = true
}

resource "aws_route53_record" "bastion_eip" {
  zone_id = "${var.route53_zone_id}"
  name    = "bastion-${var.name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.bastion_eip.public_ip}"]
}

resource "aws_autoscaling_group" "bastion" {
  name                 = "bastion-${var.name}"
  depends_on           = ["aws_launch_configuration.bastion"]
  vpc_zone_identifier  = ["${var.vpc_public_subnet_ids}"]
  max_size             = 1
  min_size             = 1
  desired_capacity     = 1
  launch_configuration = "${aws_launch_configuration.bastion.name}"
  tag {
    key                 = "Name"
    value               = "bastion-${var.name}"
    propagate_at_launch = "true"
  }
  tag {
    key                 = "Role"
    value               = "bastion"
    propagate_at_launch = "true"
  }
  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "bastion_setup_init" {
  template = "${file("${path.module}/user_data/setup_init.sh")}"
}

data "template_file" "bastion_associate_eip" {
  template = "${file("${path.module}/user_data/associate_eip.sh")}"
  vars {
    EIP_ALLOCATION_ID = "${aws_eip.bastion_eip.id}"
  }
}

resource "aws_launch_configuration" "bastion" {
  name_prefix          = "bastion-${var.name}-"
  image_id             = "${var.instance_ami_id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.bastion.id}"]
  key_name             = "${var.instance_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.bastion_instance_profile.arn}"
  root_block_device {
    volume_type = "gp2"
    volume_size = 32
  }
  user_data = "${data.template_file.bastion_setup_init.rendered}${data.template_file.bastion_associate_eip.rendered}${var.extra_user_data}"
  lifecycle {
    create_before_destroy = true
  }
}
