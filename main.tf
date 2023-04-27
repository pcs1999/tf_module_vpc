// creating the VPC
resource "aws_vpc" "dev" {
  cidr_block = var.cidr_block
  tags       = merge (local.common_tags, { Name = "${var.env}-NVPC"})
}

// creating the public subnets
resource "aws_subnet" "public" {
  count      = length(var.public_subnets_cidr)
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.public_subnets_cidr[count.index]

  tags = merge (local.common_tags, { Name = "${var.env}-public-subnet-${count.index + 1}" } )

}

// careting the private subnets
resource "aws_subnet" "private" {
  count      = length(var.private_subnets_cidr)
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.private_subnets_cidr[count.index]

  tags = merge (local.common_tags, { Name = "${var.env}-private-subnet-${count.index + 1}" } )

}

// creating the peer connection to created vpc to default vpc
resource "aws_vpc_peering_connection" "foo" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.dev.id
  tags = merge (local.common_tags, { Name = "${var.env}-peering" } )

  auto_accept = true
}


// CREATING THE PUBLIC  ROUTE TABLES
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
  }

  tags = merge (local.common_tags, { Name = "${var.env}-public_route_table" } )

}

//creating a INTERNET_GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev.id

  tags = merge (local.common_tags, { Name = "${var.env}-igw" } )

}

// associating  public routing table to public subnet
resource "aws_route_table_association" "pub_subnet-pub_rt" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id

}

// creating the ELASTIC_IP
resource "aws_eip" "ngw-elastic" {
  instance = aws_instance.web.id
  vpc      = true
}

// Creating the NAT_gateway
resource "aws_nat_gateway" "NATGW" {
  allocation_id = aws_eip.ngw-elastic.id
  subnet_id     = aws_subnet.public.*.id[0]

  tags = merge (local.common_tags, { Name = "${var.env}-NAT_GW" } )


  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  //depends_on = [aws_internet_gateway.igw]
}



// PRIVATE_Route_table_creation
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATGW.id

  }
  tags = merge (local.common_tags, { Name = "${var.env}-private_route_table" } )

}

// associating  private routing table to private subnet

resource "aws_route_table_association" "pub_subnet-pub_rt" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id

}


resource "aws_route" "route" {
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}
//creating the   EC2 instance


data "aws_ami" "example" {
  most_recent      = true
  name_regex       = "Centos-8-DevOps-Practice"
  owners           = ["973714476881"]

}

// instance
resource "aws_instance" "firstec2" {
  ami = data.aws_ami.example.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  subnet_id              = aws_subnet.private.*.id[0]

  tags = {
    Name= "automachine"
  }
}

// security group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.dev.id


  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge (local.common_tags, { Name = "${var.env}-security_group" } )

}
