data "aws_iam_policy_document" "master" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "master" {
  name               = "master_${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.master.json}"
}

resource "aws_iam_role_policy_attachment" "master_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.master.name}"
}

resource "aws_iam_role_policy_attachment" "master_service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.master.name}"
}
