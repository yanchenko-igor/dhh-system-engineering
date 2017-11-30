resource "aws_route53_zone" "vpc_internal_zone" {
  name          = "local.vpc"
  comment       = "Internal zone"
  vpc_id        = "${module.vpc1.vpc_id}"
  force_destroy = true
}

resource "aws_route53_zone" "external_zone" {
  name    = "mydomain.com"
  comment = "HostedZone created by Route53 Registrar"
}
