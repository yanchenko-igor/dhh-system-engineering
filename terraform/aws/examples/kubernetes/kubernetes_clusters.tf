module "cluster1" {
  source                      = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/kubernetes_kops_cluster/module"
  sg_allow_ssh                = "${module.ssh_bastion.allow_ssh_from_bastion_sg_id}"
  sg_allow_http_s             = "${aws_security_group.allow_http_s_from_office_ips.id}"
  cluster_name                = "cluster1"
  cluster_fqdn                = "cluster1.${aws_route53_zone.external_zone.name}"
  route53_zone_id             = "${aws_route53_zone.external_zone.id}"
  kops_s3_bucket_arn          = "${aws_s3_bucket.kops.arn}"
  kops_s3_bucket_id           = "${aws_s3_bucket.kops.id}"
  vpc_id                      = "${module.vpc1.vpc_id}"
  instance_key_name           = "default-key"
  route_table_public_id       = "${module.vpc1.public_aws_route_table_id}"
  route_table_private_id      = "${module.vpc1.private_aws_route_table_id}"
  subnet_cidr_blocks_public   = [
    "172.20.12.0/24",
    "172.20.13.0/24",
    "172.20.14.0/24"
  ]
  subnet_cidr_blocks_private  = [
    "172.20.15.0/24",
    "172.20.16.0/24",
    "172.20.17.0/24"
  ]
  node_asg_desired            = 3
  node_asg_min                = 3
  node_asg_max                = 3
  master_instance_type        = "t2.small"
  node_instance_type          = "t2.small"
  master_iam_instance_profile = "${aws_iam_instance_profile.kubernetes_masters.id}"
  node_iam_instance_profile   = "${aws_iam_instance_profile.kubernetes_nodes.id}"
}

module "cluster2" {
  source                      = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/kubernetes_kops_cluster/module"
  sg_allow_ssh                = "${module.ssh_bastion.allow_ssh_from_bastion_sg_id}"
  sg_allow_http_s             = "${aws_security_group.allow_http_s_from_office_ips.id}"
  cluster_name                = "cluster2"
  cluster_fqdn                = "cluster2.${aws_route53_zone.external_zone.name}"
  route53_zone_id             = "${aws_route53_zone.external_zone.id}"
  kops_s3_bucket_arn          = "${aws_s3_bucket.kops.arn}"
  kops_s3_bucket_id           = "${aws_s3_bucket.kops.id}"
  vpc_id                      = "${module.vpc1.vpc_id}"
  instance_key_name           = "default-key"
  route_table_public_id       = "${module.vpc1.public_aws_route_table_id}"
  route_table_private_id      = "${module.vpc1.private_aws_route_table_id}"
  subnet_cidr_blocks_public   = [
    "172.20.18.0/24",
    "172.20.19.0/24",
    "172.20.20.0/24"
  ]
  subnet_cidr_blocks_private  = [
    "172.20.21.0/24",
    "172.20.22.0/24",
    "172.20.23.0/24"
  ]
  node_asg_desired            = 2
  node_asg_min                = 2
  node_asg_max                = 2
  master_instance_type        = "t2.small"
  node_instance_type          = "t2.small"
  master_iam_instance_profile = "${aws_iam_instance_profile.kubernetes_masters.id}"
  node_iam_instance_profile   = "${aws_iam_instance_profile.kubernetes_nodes.id}"
}
