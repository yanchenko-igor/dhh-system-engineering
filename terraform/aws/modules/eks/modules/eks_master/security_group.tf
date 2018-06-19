resource "aws_security_group" "master" {
  name        = "eks_master_${var.cluster_name}"
  description = "EKS master cluster ${var.cluster_name}"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "eks_master_${var.cluster_name}"
  }
}
