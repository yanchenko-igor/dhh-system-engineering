resource "aws_security_group" "allow_http_s_from_internet" {
  name        = "allow_http_s_from_internet"
  vpc_id      = "${module.vpc1.vpc_id}"
  description = "Allows HTTP/S access from anywhere"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_http_s_from_internet"
  }
}

resource "aws_security_group" "allow_http_s_inside_vpc" {
  name        = "allow_http_s_inside_vpc"
  vpc_id      = "${module.vpc1.vpc_id}"
  description = "Allow HTTP/S access inside VPC"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc1.cidr_block}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc1.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_http_s_inside_vpc"
  }
}

resource "aws_security_group" "allow_ssh_from_office_ips" {
  name_prefix = "allow_ssh_from_office_ips-"
  vpc_id      = "${module.vpc1.vpc_id}"
  description = "Allows SSH from office IPs"

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
    Name = "allow_ssh_from_office_ips"
  }
}

resource "aws_security_group" "allow_http_s_from_office_ips" {
  name_prefix = "allow_http_s_from_office_ips-"
  vpc_id      = "${module.vpc1.vpc_id}"
  description = "Allows HTTP/S from office IPs"

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
    Name = "allow_http_s_from_office_ips"
  }
}

resource "aws_security_group_rule" "allow_ssh_from_office_ips" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = "${var.office_ips}"
  security_group_id = "${aws_security_group.allow_ssh_from_office_ips.id}"
}

resource "aws_security_group_rule" "allow_http_from_office_ips_sg_rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = "${var.office_ips}"
  security_group_id = "${aws_security_group.allow_http_s_from_office_ips.id}"
}

resource "aws_security_group_rule" "allow_https_from_office_ips_sg_rule" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = "${var.office_ips}"
  security_group_id = "${aws_security_group.allow_http_s_from_office_ips.id}"
}
