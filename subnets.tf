module "subnets" {
  source                    = "./subnets"

  for_each                  = var.subnets

  env                       = var.env
  availability_zones        = var.availability_zones
  default_vpc_id            = var.default_vpc_id

  name                      = each.value.name
  cidr_block                = each.value.cidr_block

  vpc_id                    = aws_vpc.dev_vpc.id
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id

  internet_gw = lookup(each.value, "internet-gw" , false )
  nat_gw = lookup(each.value,"nat_gw",false )
  create_nat_gw = lookup(each.value,"create_nat_gw",false )

}