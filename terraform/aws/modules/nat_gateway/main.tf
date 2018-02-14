resource "aws_eip" "nat_gateway" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc   = true
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = "${length(data.aws_availability_zones.available.names)}"
  allocation_id = "${element(aws_eip.nat_gateway.*.id, count.index)}"
  subnet_id     = "${element(var.vpc_public_subnet_ids, count.index)}"
}

resource "aws_route_table" "nat_private" {
  count  = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat_gateway.*.id, count.index)}"
  }

  tags {
    "Name" = "nat_private ${element(split(",", "a,b,c"), count.index)}"
  }
}

resource "aws_subnet" "nat_private" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${element(var.nat_private_subnet_cidrs, count.index)}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = false

  tags {
    "Name" = "nat_private ${element(split(",", "a,b,c"), count.index)}"
  }
}

resource "aws_route_table_association" "nat_gateway_private" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  route_table_id = "${element(aws_route_table.nat_private.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.nat_private.*.id, count.index)}"
}
