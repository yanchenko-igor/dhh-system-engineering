resource "aws_iam_role" "security_monkey" {
  name               = "${var.role_name}"
  assume_role_policy = "${data.aws_iam_policy_document.security_monkey_assume_role_policy.json}"
}

data "aws_iam_policy_document" "security_monkey_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:role/${var.assume_role_name}"]
    }
  }
}

resource "aws_iam_policy_attachment" "security_monkey" {
  name       = "${var.role_name}_attachment"
  roles      = [
    "${aws_iam_role.security_monkey.name}"
  ]
  policy_arn = "${aws_iam_policy.security_monkey.arn}"
}

resource "aws_iam_policy" "security_monkey" {
  name        = "${var.role_name}_policy"
  description = "Policy for security_monkey"
  policy      =  "${data.aws_iam_policy_document.security_monkey.json}"
}

data "aws_iam_policy_document" "security_monkey" {
  statement {
    effect    = "Allow"
    actions   = [
      "acm:describecertificate",
      "acm:listcertificates",
      "cloudtrail:describetrails",
      "cloudtrail:gettrailstatus",
      "config:describeconfigrules",
      "config:describeconfigurationrecorders",
      "directconnect:describeconnections",
      "ec2:describeaddresses",
      "ec2:describedhcpoptions",
      "ec2:describeflowlogs",
      "ec2:describeimages",
      "ec2:describeinstances",
      "ec2:describeinternetgateways",
      "ec2:describekeypairs",
      "ec2:describenatgateways",
      "ec2:describenetworkacls",
      "ec2:describenetworkinterfaces",
      "ec2:describeregions",
      "ec2:describeroutetables",
      "ec2:describesecuritygroups",
      "ec2:describesnapshots",
      "ec2:describesubnets",
      "ec2:describetags",
      "ec2:describevolumes",
      "ec2:describevpcendpoints",
      "ec2:describevpcpeeringconnections",
      "ec2:describevpcs",
      "elasticloadbalancing:describeloadbalancerattributes",
      "elasticloadbalancing:describeloadbalancerpolicies",
      "elasticloadbalancing:describeloadbalancers",
      "es:describeelasticsearchdomainconfig",
      "es:listdomainnames",
      "iam:getaccesskeylastused",
      "iam:getgroup",
      "iam:getgrouppolicy",
      "iam:getloginprofile",
      "iam:getpolicyversion",
      "iam:getrole",
      "iam:getrolepolicy",
      "iam:getservercertificate",
      "iam:getuser",
      "iam:getuserpolicy",
      "iam:listaccesskeys",
      "iam:listattachedgrouppolicies",
      "iam:listattachedrolepolicies",
      "iam:listattacheduserpolicies",
      "iam:listentitiesforpolicy",
      "iam:listgrouppolicies",
      "iam:listgroups",
      "iam:listinstanceprofilesforrole",
      "iam:listmfadevices",
      "iam:listpolicies",
      "iam:listrolepolicies",
      "iam:listroles",
      "iam:listservercertificates",
      "iam:listsigningcertificates",
      "iam:listuserpolicies",
      "iam:listusers",
      "kms:describekey",
      "kms:getkeypolicy",
      "kms:listaliases",
      "kms:listgrants",
      "kms:listkeypolicies",
      "kms:listkeys",
      "lambda:listfunctions",
      "rds:describedbclusters",
      "rds:describedbclustersnapshots",
      "rds:describedbinstances",
      "rds:describedbsecuritygroups",
      "rds:describedbsnapshots",
      "rds:describedbsubnetgroups",
      "redshift:describeclusters",
      "route53:listhostedzones",
      "route53:listresourcerecordsets",
      "route53domains:listdomains",
      "route53domains:getdomaindetail",
      "s3:getaccelerateconfiguration",
      "s3:getbucketacl",
      "s3:getbucketcors",
      "s3:getbucketlocation",
      "s3:getbucketlogging",
      "s3:getbucketnotification",
      "s3:getbucketpolicy",
      "s3:getbuckettagging",
      "s3:getbucketversioning",
      "s3:getbucketwebsite",
      "s3:getlifecycleconfiguration",
      "s3:listallmybuckets",
      "s3:getreplicationconfiguration",
      "s3:getanalyticsconfiguration",
      "s3:getmetricsconfiguration",
      "s3:getinventoryconfiguration",
      "ses:getidentityverificationattributes",
      "ses:listidentities",
      "ses:listverifiedemailaddresses",
      "ses:sendemail",
      "sns:gettopicattributes",
      "sns:listsubscriptionsbytopic",
      "sns:listtopics",
      "sqs:getqueueattributes",
      "sqs:listqueues"
    ]
    resources = ["*"]
  }
}
