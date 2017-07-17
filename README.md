# Delivery Hero System Engineering

This repository contains [Terraform](https://www.terraform.io/) modules and best practice examples to give a head start when building a new AWS environment.

The intended audience is teams or projects that are starting with AWS and want to begin with a good design.

Pull requests welcome!

## AWS

### Terraform modules

- [autoscaling_group_elb_app](terraform/aws/modules/autoscaling_group_elb_app): An example of EC2 autoscaling group and ELB.
- [kubernetes_kops_cluster](terraform/aws/modules/kubernetes_kops_cluster): A Kubernetes cluster with multi-AZ master based on [kops](https://github.com/kubernetes/kops).
- [lambda_kubernetes_deployer](terraform/aws/modules/lambda_kubernetes_deployer): A lambda function that deploys to a Kubernetes cluster when a container image is pushed to ECR.
- [lambda_splunk_forwarder](terraform/aws/modules/lambda_splunk_forwarder): A lambda function for forwarding Cloudwatch logs to a Splunk HTTP events collector.
- [nat_gateway](terraform/aws/modules/nat_gateway): NAT gateway.
- [ssh_bastion](terraform/aws/modules/ssh_bastion): SSH bastion host in an ASG with a fixed EIP.
- [vpc](terraform/aws/modules/vpc): A VPC setup that includes public and private subnets for each AZ, route tables.

### Examples

- [base](terraform/aws/examples/base): A good starting point with a VPC and related resources, SSH bastion, some default security groups and S3 bucket for Terraform state.
- [kubernetes](terraform/aws/examples/kubernetes): Same as `base` example but with shared kubernetes resources and 2 kubernetes clusters added.

## GCP

### Terraform modules

- [splunk_logging](terraform/gcp/modules/splunk_logging): PubSub, service account and IAM policy to allow Splunk to pull logs from GKE/GCP.

### Examples

- [GKE Cluster](terraform/gcp/examples/gke_cluster.tf): A Container Engine cluster with autoscaling enabled
- [terraform](terraform/gcp/examples/terraform.tf): Remote state stored on a Google Storage Bucket

## Kubernetes

### Examples

- [Deployment and Service](kubernetes/examples/deployment_service): A simple example of a Kubernetes deployment, different service types and a horizontal pod autoscaler.

## Dos and Don'ts

- Do make pull requests to this repository.
- Don't bother using a NAT gateway unless you specifically need a fixed source IP address for outgoing traffic.
- Do store your Terraform state in a bucket.
- Do use an internal Route53 zone to hold records for RDS endpoints, ES endpoints, Elasticache endpoints etc.
- Do terminate SSL on ELBs and forward as HTTP in VPC. This means you never need to deal with SSL or certificates on instances.
- Do use a SSH bastion for all SSH connections and restrict SSH access by IP ranges.
- Consider registering an external domain in Route53. It only costs a few dollars and you can have a free SSL certificate. Then use this domain and certificate for all external ELBs.
- Don't have instances that are not part of an Austoscaling Group.
