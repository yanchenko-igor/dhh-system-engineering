resource "aws_iam_instance_profile" "app" {
  name = "${var.app_name}_app"
  role = "${aws_iam_role.app.name}"
}

resource "aws_iam_role" "app" {
  name               = "${var.app_name}_app"
  assume_role_policy = "${data.aws_iam_policy_document.app_assume_role_policy.json}"
}

data "aws_iam_policy_document" "app_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy_attachment" "app" {
  name       = "${var.app_name}_app"
  roles      = ["${aws_iam_role.app.name}"]
  policy_arn = "${aws_iam_policy.app.arn}"
}

data "aws_iam_policy_document" "app" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "app" {
  name        = "${var.app_name}_app"
  description = "Policy for ${var.app_name} app instances"
  policy      = "${data.aws_iam_policy_document.app.json}"
}
