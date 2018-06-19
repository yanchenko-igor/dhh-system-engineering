# EKS master and nodes

## Example

```hcl
module "cluster_1_master" {
  source         = "modules/eks_master"
  cluster_name   = "cluster_1"
  vpc_id         = "${aws_vpc.eks.id}"
  kubeconfig_dir = "kubeconfig"
  subnet_ids     = ["${aws_subnet.public.*.id}"]
}

module "cluster_1_node" {
  source                = "modules/eks_node"
  cluster_name          = "${module.cluster_1_master.cluster_name}"
  vpc_id                = "${aws_vpc.eks.id}"
  subnet_ids            = ["${aws_subnet.public.*.id}"]
  extra_security_groups = ["${aws_security_group.allow_ssh.id}"]
  master_sg_id          = "${module.cluster_1_master.sg_id}"
  cluster_ca_data       = "${module.cluster_1_master.ca_data}"
  cluster_endpoint      = "${module.cluster_1_master.cluster_endpoint}"
  kubeconfig_path       = "${module.cluster_1_master.kubeconfig_path}"
}
```
