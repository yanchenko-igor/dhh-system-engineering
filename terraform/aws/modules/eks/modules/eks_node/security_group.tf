resource "aws_security_group" "node" {
  name        = "node_${var.cluster_name}"
  description = "EKS cluster ${var.cluster_name} nodes"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "node_${var.cluster_name}",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "node_to_self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node_to_cluster_1" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${var.master_sg_id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node_to_cluster_2" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${var.master_sg_id}"
  source_security_group_id = "${aws_security_group.node.id}"
  to_port                  = 443
  type                     = "ingress"
}
