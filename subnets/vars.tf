variable "cidr_block" {}
variable "availability_zones" {}
variable "env" {}
variable "default_vpc_id" {}
variable "vpc_id" {}
variable "name" {}
variable "vpc_peering_connection_id" {}
variable "nat_gw" {}
variable "internet_gw" {}
variable "tags" {}
variable "gateway_id" {
  default = null
}
variable "nat_gw_id" {
  default = null
}

