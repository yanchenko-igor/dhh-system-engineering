variable "vpc_name" {
  default = "main_vpc"
}
variable "vpc_cidr_block" {
  default = "172.20.0.0/16"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}
output "cidr_block" {
  value = "${aws_vpc.vpc.cidr_block}"
}
output "vpc_public_subnet_ids" {
  value = ["${aws_subnet.public.*.id}"]
}
output "vpc_private_subnet_ids" {
  value = ["${aws_subnet.private.*.id}"]
}
output "private_aws_route_table_id" {
  value = "${aws_route_table.private.id}"
}
output "public_aws_route_table_id" {
  value = "${aws_route_table.public.id}"
}
output "internet_gateway_id" {
  value = "${aws_internet_gateway.internet_gateway.id}"
}
