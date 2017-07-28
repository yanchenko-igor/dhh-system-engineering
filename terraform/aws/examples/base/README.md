# Base design

Here is a good example to use a base design for a new environment.

Features:

  - Terraform state stored in a bucket
  - Internal Route53 zone
  - SSH bastion for all SSH connections
  - Default security groups to allow SSH from trusted list of IPs (`office_ips` variable)
  - Cloudtrail enabled
  - Public and private subnets for each availability zone

## Get started

Copy the `*.tf` files to your repo.

Set your AWS region and `office_ips` in `variables.tf` if required.

Run:

```
export AWS_ACCESS_KEY_ID=AKIAJJJJJJJJJJJJ
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXX
terraform get
terraform init
terraform plan
terraform apply
```

Then update terraform backend configuration in `terraform.tf` to use the S3 bucket for remote state.
