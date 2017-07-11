# VPC

Creates a VPC, public and private subnets for each AZ, route tables and internet gateway.

## Example

Single VPC:

```
module "main_vpc" {
  source = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/vpc"
}
```

Multiple VPCs:

```
module "vpc1" {
  source         = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/vpc"
  vpc_name       = "vpc1"
  vpc_cidr_block = "10.0.0.0/16"
}

module "vpc2" {
  source         = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/vpc"
  vpc_name       = "vpc2"
  vpc_cidr_block = "10.1.0.0/16"
}
```

## Notes

`vpc_cidr_block` must be /16 or larger.
