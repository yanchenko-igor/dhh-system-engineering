variable "vpc_id" {}

# List of CIDR ranges to use for the private subnets of each NAT gateway
variable "nat_private_subnet_cidrs" {
  type = "list"
}

# List of existing public subnet IDs that each NAT gateway instance will be associated with
variable "vpc_public_subnet_ids" {
  type = "list"
}

output "eip_public_ips" {
  value = ["${aws_eip.nat_gateway.*.public_ip}"]
}

output "nat_private_subnet_ids" {
  value = ["${aws_subnet.nat_private.*.id}"]
}
