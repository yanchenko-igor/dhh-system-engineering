resource "aws_security_group_rule" "allow_ssh_ssh_cidr_blocks" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = "${var.allowed_ssh_cidr_blocks}"
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group" "bastion" {
  name_prefix = "bastion-${var.name}-"
  vpc_id      = "${var.vpc_id}"
  description = "Bastion instance (${var.name})"

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
    Name = "bastion-${var.name}"
  }
}

resource "aws_security_group" "allow_ssh_from_bastion" {
  name        = "allow_ssh_from_bastion-${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Allows SSH access from bastion security host (${var.name})"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  tags {
    Name = "allow_ssh_from_bastion-${var.name}"
  }
}
