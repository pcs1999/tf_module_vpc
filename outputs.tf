output "vpc_id" {
  value = aws_vpc.dev_vpc.id
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.foo.id
}

