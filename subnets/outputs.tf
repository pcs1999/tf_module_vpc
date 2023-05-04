output "subnet_id" {
  value = aws_subnet.main.*.id
}

#output "vpc_peering_connection_id" {
#  value = aws_vpc_peering_connection.foo.id
#}
#
#output "public_subnets_ids" {
#  value = module.public_subnets.subnet_id
#}
#
#output "one_subnet" {
#  value = module.public_subnets["public"]["subnet_ids"][0]
#}