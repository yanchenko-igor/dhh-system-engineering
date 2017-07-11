resource "aws_route53_zone" "vpc_internal_zone" {
  name    = "local.vpc"
  comment = "Internal zone"
}
