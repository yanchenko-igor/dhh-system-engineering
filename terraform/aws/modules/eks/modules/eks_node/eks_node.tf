data "aws_ami" "eks_worker_ami_id" {
  filter {
    name   = "name"
    values = ["eks-worker-*"]
  }

  most_recent = true
  owners      = ["602401143452"]
}

locals {
  node_userdata = <<USERDATA
#!/bin/bash -xe

CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
mkdir -p $CA_CERTIFICATE_DIRECTORY
echo "${var.cluster_ca_data}" | base64 -d >  $CA_CERTIFICATE_FILE_PATH
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i s,MASTER_ENDPOINT,${var.cluster_endpoint},g /var/lib/kubelet/kubeconfig
sed -i s,CLUSTER_NAME,${var.cluster_name},g /var/lib/kubelet/kubeconfig
sed -i s,REGION,${data.aws_region.current.name},g /etc/systemd/system/kubelet.service
sed -i s,MAX_PODS,${var.cluster_max_pods},g /etc/systemd/system/kubelet.service
sed -i s,MASTER_ENDPOINT,${var.cluster_endpoint},g /etc/systemd/system/kubelet.service
sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service
DNS_CLUSTER_IP=10.100.0.10
if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi
sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service
systemctl daemon-reload
systemctl restart kubelet
USERDATA
}

resource "aws_launch_configuration" "node" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.node.name}"
  image_id                    = "${data.aws_ami.eks_worker_ami_id.id}"
  key_name                    = "${var.node_key_name}"
  instance_type               = "${var.node_instance_type}"
  name_prefix                 = "node_${var.cluster_name}_"
  security_groups             = ["${concat(list(aws_security_group.node.id), var.extra_security_groups)}"]
  user_data_base64            = "${base64encode(local.node_userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "node" {
  depends_on = [
    "null_resource.node_auth_update",
  ]

  name                 = "eks_node_${var.cluster_name}"
  launch_configuration = "${aws_launch_configuration.node.id}"
  max_size             = 20
  min_size             = "${var.node_count}"
  desired_capacity     = "${var.node_count}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "node"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  # Ignore changes to autoscaling group min/max/desired as these attributes are
  # managed by the Kubernetes cluster autoscaler addon
  lifecycle {
    ignore_changes = [
      "max_size",
      "min_size",
      "desired_capacity",
    ]
  }
}
