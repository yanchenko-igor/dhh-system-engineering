# Base with multiple Kubernetes clusters

Based on the [base](terraform/aws/examples/base) example but with Kubernetes resources and clusters added.

## Get started

Copy the `*.tf` files to your repo.

Set your AWS region and `office_ips` in `variables.tf` if required.

Run:

```
terraform get
terraform init
terraform plan
terraform apply
```

Then update terraform backend configuration in `terraform.tf` to use the S3 bucket for remote state.
