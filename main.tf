resource "aws_vpc" "dev" {
  cidr_block = var.cidr_block
  tags       = merge (local.common_tags, { Name = "${var.env}-vpc"})
}


resource "aws_subnet" "main-dev" {
  count      = length(var.subnets_cidr)
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.subnets_cidr[count.index]

  tags = merge (local.common_tags, { Name = "${var.env}-subnet{count.index+2}"})

}

resource "aws_vpc_peering_connection" "foo" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.dev.id
  tags = {
    Name = "${var.env}-peering"
  }
  auto_accept = true
}

resource "aws_route" "default" {
  route_table_id            = aws_vpc.dev.default_route_table_id
  destination_cidr_block    = "172.31.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id

}