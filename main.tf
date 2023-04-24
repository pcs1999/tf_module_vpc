resource "aws_vpc" "dev" {
  cidr_block = var.cidr_block
  tags       = merge (local.common_tags, { Name = "${var.env}-vpc"})
}


resource "aws_subnet" "main-dev" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.cidr_block

  tags = merge (local.common_tags, { Name = "${var.env}-subnet"})

}