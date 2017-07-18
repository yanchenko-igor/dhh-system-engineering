# NAT gateway

Creates per AZ NAT gateways with elastic IPs, subnets and a route table.

## Example

```hcl
module "nat_gateway" {
  source                   = "github.com/deliveryhero/dhh-system-engineering/terraform/aws/modules/nat_gateway"
  vpc_id                   = "${module.vpc1.vpc_id}"
  vpc_public_subnet_ids    = ["${module.vpc1.vpc_public_subnet_ids}"]
  nat_private_subnet_cidrs = [
    "172.20.12.0/23",
    "172.20.14.0/23",
    "172.20.16.0/23"
  ]
}
```
