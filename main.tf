// creating the VPC
resource "aws_vpc" "dev_vpc" {
  cidr_block = var.cidr_block
  tags       = merge (local.common_tags, { Name = "${var.env}-VPC"})
}


// creating the peer connection to created vpc to default vpc
resource "aws_vpc_peering_connection" "foo" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.dev_vpc.id
  tags = merge (local.common_tags, { Name = "${var.env}-peering" } )

  auto_accept = true
}


//creating a INTERNET_GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = merge (local.common_tags, { Name = "${var.env}-igw" } )

}


// creating the ELASTIC_IP
resource "aws_eip" "ngw-elastic" {
  vpc      = true
}

// Creating the NAT_gateway
#resource "aws_nat_gateway" "NATGW" {
#  allocation_id = aws_eip.ngw-elastic.id
#  subnet_id     = aws_subnet.public.*.id[0]
#
#  tags = merge (local.common_tags, { Name = "${var.env}-NAT_GW" } )
#
#
#  # To ensure proper ordering, it is recommended to add an explicit dependency
#  # on the Internet Gateway for the VPC.
#  //depends_on = [aws_internet_gateway.igw]
#}



resource "aws_route" "route" {
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}

