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





#// creating the ELASTIC_IP
#resource "aws_eip" "ngw-elastic" {
#  vpc      = true
#}





resource "aws_route" "route" {
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}



