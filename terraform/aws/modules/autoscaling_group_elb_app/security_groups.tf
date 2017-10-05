resource "aws_security_group" "app_instances" {
  name_prefix = "${var.app_name}_app_instances-"
  vpc_id      = "${var.vpc_id}"
  description = "${var.app_name} app instances"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app_elb.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "${var.app_name}_app_instances"
  }
}

resource "aws_security_group" "app_elb" {
  name        = "${var.app_name}_app_elb"
  vpc_id      = "${var.vpc_id}"
  description = "App ELB ${var.app_name}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.app_name}_app_elb"
  }
}
