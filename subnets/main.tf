// creating the subnets
resource "aws_subnet" "main" {
  count = length(var.cidr_block)
  cidr_block = var.cidr_block[count.index]
  availability_zone = var.availability_zones[count.index]
  vpc_id = var.vpc_id
  tags = merge(local.common_tags, { Name = "${var.env}-${var.name}-subnet-${count.index + 1}" })
}

// creating the routing table
resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block        = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = var.vpc_peering_connection_id
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      route,
    ]
  }

  tags = merge(local.common_tags, { Name = "${var.env}-${var.name}-route_table"})
}

// route table association to subnets
resource "aws_route_table_association" "association" {
  count = length(aws_subnet.main)
  subnet_id      = aws_subnet.main.*.id[count.index]
  route_table_id = aws_route_table.route_table.id
}

// creating a route to igw
resource "aws_route" "gw_route" {
  count = var.internet_gw  ? 1 : 0
  route_table_id = aws_route_table.route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = var.gateway_id

}

// creating a route to nat_gw
resource "aws_route" "nat_gw_route" {
  count = var.nat_gw  ? 1 : 0
  route_table_id = aws_route_table.route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = var.nat_gw_id

}