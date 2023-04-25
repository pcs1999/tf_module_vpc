resource "aws_vpc" "dev" {
  cidr_block = var.cidr_block
  tags       = merge (local.common_tags, { Name = "${var.env}-NVPC"})
}


resource "aws_subnet" "main-dev" {
  count      = length(var.subnets_cidr)
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.subnets_cidr[count.index]

  tags = merge (local.common_tags, { Name = "${var.env}-subnet-${count.index + 1}" } )

}

resource "aws_vpc_peering_connection" "foo" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.dev.id
  tags = merge (local.common_tags, { Name = "${var.env}-peering" } )

  auto_accept = true
}

resource "aws_route" "default" {
  route_table_id            = aws_vpc.dev.default_route_table_id
  destination_cidr_block    = "172.31.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id

}

resource "aws_route" "default-vpc" {
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id

}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev.id

  tags = merge (local.common_tags, { Name = "${var.env}-igw" } )

}

//create ec2
#provider "aws" {
#  region = "us-east-1"
#}
#
#data "aws_ami" "centos8" {
#  most_recent = true
#  name_regex  = "Centos-8-DevOps-Practice"
#  owners      = ["973714476881"]
#}
#
#resource "aws_instance" "web" {
#  ami                    = data.aws_ami.centos8.id
#  instance_type          = "t3.micro"
#  vpc_security_group_ids = [aws_security_group.allow_tls.id]
#  subnet_id              = aws_subnet.main-dev.*.id[0]
#
#  tags = {
#    Name = "test-centos8"
#  }
#}
#
#
#terraform {
#  backend "s3" {
#    bucket = "terraform-b70"
#    key    = "05-remote-state/terraform.tfstate"
#    region = "us-east-1"
#  }
#}
#
#//security_groeup
#
#resource "aws_security_group" "allow_tls" {
#  name        = "allow_tls"
#  description = "Allow TLS inbound traffic"
#  vpc_id      = aws_vpc.dev.id
#
#  ingress {
#    description = "TLS from VPC"
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  egress {
#    from_port        = 0
#    to_port          = 0
#    protocol         = "-1"
#    cidr_blocks      = ["0.0.0.0/0"]
#    ipv6_cidr_blocks = ["::/0"]
#  }
#
#  tags = {
#    Name = "allow_tls"
#  }
#}
