resource "aws_autoscaling_group" "app" {
  name                 = "${var.app_name}_app"
  depends_on           = ["aws_launch_configuration.app"]
  vpc_zone_identifier  = ["${var.vpc_public_subnet_ids}"]
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.app.name}"
  load_balancers       = ["${aws_elb.app.name}"]

  tag {
    key                 = "Name"
    value               = "${var.app_name}_app"
    propagate_at_launch = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "app" {
  name_prefix          = "${var.app_name}_app"
  image_id             = "${var.instance_ami_id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.app_instances.id}", "${var.sg_allow_ssh}"]
  key_name             = "${var.instance_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.app.name}"
  user_data            = "${var.instance_user_data}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 32
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "app" {
  name                      = "${var.app_name}-app"
  cross_zone_load_balancing = true
  security_groups           = ["${aws_security_group.app_elb.id}", "${var.sg_allow_http_s}"]
  subnets                   = ["${var.vpc_public_subnet_ids}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 30
  }

  tags {
    Name = "${var.app_name}_app"
  }
}
