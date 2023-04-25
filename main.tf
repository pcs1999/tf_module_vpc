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
  peer_vpc_id   = "vpc-0738d5702c63820c7"
  vpc_id        = aws_vpc.dev.id
  auto_accept = true
}