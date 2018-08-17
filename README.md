# Delivery Hero System Engineering

This repository contains [Terraform](https://www.terraform.io/) modules, Kubernetes configuration and other best practice examples to give groups within DH a head start when building a new environment on AWS or Kubernetes.

The intended audience is teams or projects that are starting with AWS or Kubernetes and want to begin with a good design.

Pull requests welcome!

## Terraform modules

- [aws_sso](terraform/aws/modules/aws_sso): Creates an Identity Provider in IAM and some default roles to be used for SSO.
- [autoscaling_group_elb_app](terraform/aws/modules/autoscaling_group_elb_app): An example of EC2 autoscaling group and ELB.
- [kubernetes_kops_cluster](https://github.com/FutureSharks/tf-kops-cluster): A Kubernetes cluster with multi-AZ master based on [kops](https://github.com/kubernetes/kops).
- [lambda_kubernetes_deployer](terraform/aws/modules/lambda_kubernetes_deployer): A lambda function that deploys to a Kubernetes cluster when a container image is pushed to an ECR repository.
- [lambda_splunk_forwarder](terraform/aws/modules/lambda_splunk_forwarder): A lambda function for forwarding Cloudwatch logs to a Splunk HTTP events collector.
- [nat_gateway](terraform/aws/modules/nat_gateway): Creates multi-AZ NAT gateways, associated private subnets and route tables.
- [ssh_bastion](https://github.com/deliveryhero/tf-ssh-bastion): SSH bastion host in an ASG with a fixed EIP.
- [security_monkey](terraform/aws/modules/security_monkey): IAM role and associated policy to run Netflix's [Security Monkey](https://github.com/Netflix/security_monkey).
- [vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc): A very flexible VPC module.
- [EKS](https://github.com/terraform-aws-modules/terraform-aws-eks): Terraform module to create EKS master and nodes.
- [RDS Aurora](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora): Terraform module to create an RDS Aurora cluster.

## Kubernetes Examples

- [Deployment, Service and Autoscaling](kubernetes/examples/deployment_service): A simple example of a Kubernetes deployment, different service types and a horizontal pod autoscaler.
- [Helm templating](kubernetes/examples/helm): A simple example using Helm to template Kubernetes resources.
- [Ingress Controller](kubernetes/examples/ingress): Using an Ingress controller and resource to split traffic across multiple applications.
- [ExternalDNS](kubernetes/examples/external-dns): A tool that automatically creates DNS records for Kubernetes resources.
- [Kubernetes Best Practices](https://speakerdeck.com/thesandlord/kubernetes-best-practices): A great presentation from a Google engineer.
- [Kubernetes OpenID Connect authenticator](kubernetes/examples/k8s-oidc-authenticator): API Authentication using Google OIDC
- [Kubernetes dashboard with OAuth2](kubernetes/examples/dashboard-oauth): Run the Kubernetes dashboard behind OAuth2

## Other useful tools

#### Keymaker

Lightweight SSH key management on AWS EC2. Add public SSH keys to IAM users and then they can log into EC2 hosts.

https://github.com/kislyuk/keymaker

#### Elasticsearch on Kubernetes

https://github.com/pires/kubernetes-elasticsearch-cluster

#### Invokust

Run [Locust](http://locust.io/) load tests on AWS Lambda.

https://github.com/FutureSharks/invokust

#### Helm

[Helm](https://github.com/kubernetes/helm) is a powerful tool for creating templates for Kubernetes resources, creating reproducible builds or for packaging and installing predefined configurations for services.
