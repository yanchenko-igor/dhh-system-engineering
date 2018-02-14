resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "bastion_instance_profile-${var.name}"
  role = "${aws_iam_role.bastion_ec2_role.name}"
}

resource "aws_iam_role" "bastion_ec2_role" {
  name = "bastion_ec2_role-${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "bastion_ec2_role_policy" {
  name = "bastion-ec2-role-policy-${var.name}"
  role = "${aws_iam_role.bastion_ec2_role.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*",
        "cloudwatch:PutMetric*",
        "cloudwatch:DeleteAlarms",
        "ec2:Describe*",
        "ec2:CreateTags",
        "ec2:AssociateAddress",
        "ec2:DescribeAddresses",
        "ec2:DisassociateAddress",
        "iam:GetSSHPublicKey",
        "iam:ListSSHPublicKeys",
        "iam:GetUser",
        "iam:GetGroup",
        "iam:ListGroupsForUser",
        "iam:ListGroups",
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
