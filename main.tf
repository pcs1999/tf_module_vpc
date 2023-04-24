resource "aws_vpc" "dev" {
  cidr_block = var.cidr_block
  tags       = merge (local.common_tags, { Name = "${var.env}-vpc"})
}
