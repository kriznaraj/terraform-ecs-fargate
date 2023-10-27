provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    
  }
}

resource "aws_vpc" "revmonk-prod-vpc" {
  cidr_block            = "${var.vpc_cidr}"
  enable_dns_hostnames  = true

  tags = {
    Name = "revmonk-prod-vpc"
  }
}

resource "aws_subnet" "public-subnet-1" {
  cidr_block        = "${var.public_subnet_1_cidr}"
  vpc_id            = "${aws_vpc.revmonk-prod-vpc.id}"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  cidr_block        = "${var.public_subnet_2_cidr}"
  vpc_id            = "${aws_vpc.revmonk-prod-vpc.id}"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "public-subnet-3" {
  cidr_block        = "${var.public_subnet_3_cidr}"
  vpc_id            = "${aws_vpc.revmonk-prod-vpc.id}"
  availability_zone = "us-east-1c"
  
  tags = {
    Name = "public-subnet-3"
  }
}

resource "aws_subnet" "private-subnet-1" {
  cidr_block        = "${var.private_subnet_1_cidr}"
  vpc_id            = "${aws_vpc.revmonk-prod-vpc.id}"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  cidr_block        = "${var.private_subnet_2_cidr}"
  vpc_id            = "${aws_vpc.revmonk-prod-vpc.id}"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_subnet" "private-subnet-3" {
  cidr_block        = "${var.private_subnet_3_cidr}"
  vpc_id            = "${aws_vpc.revmonk-prod-vpc.id}"
  availability_zone = "us-east-1c"
  
  tags = {
    Name = "private-subnet-3"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = "${aws_vpc.revmonk-prod-vpc.id}"
  tags = {
    Name = "public-route_table"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = "${aws_vpc.revmonk-prod-vpc.id}"
  tags = {
    Name = "private-route_table"
  }
}

resource "aws_route_table_association" "public-subnet-1-association" {
  route_table_id    = "${aws_route_table.public-route-table.id}"
  subnet_id         = "${aws_subnet.public-subnet-1.id}"
}

resource "aws_route_table_association" "public-subnet-2-association" {
  route_table_id    = "${aws_route_table.public-route-table.id}"
  subnet_id         = "${aws_subnet.public-subnet-2.id}"
}

resource "aws_route_table_association" "public-subnet-3-association" {
  route_table_id    = "${aws_route_table.public-route-table.id}"
  subnet_id         = "${aws_subnet.public-subnet-3.id}"
}

resource "aws_route_table_association" "private-subnet-1-association" {
  route_table_id    = "${aws_route_table.private-route-table.id}"
  subnet_id         = "${aws_subnet.private-subnet-1.id}"
}

resource "aws_route_table_association" "private-subnet-2-association" {
  route_table_id    = "${aws_route_table.private-route-table.id}"
  subnet_id         = "${aws_subnet.private-subnet-2.id}"
}

resource "aws_route_table_association" "private-subnet-3-association" {
  route_table_id    = "${aws_route_table.private-route-table.id}"
  subnet_id         = "${aws_subnet.private-subnet-3.id}"
}


resource "aws_eip" "elastic-ip-for-nat-gw" {
#   vpc = true
  associate_with_private_ip = "10.0.0.5"

#   tags {
#     Name = "Prod-EIP"
#   }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.elastic-ip-for-nat-gw.id}"
  subnet_id = "${aws_subnet.public-subnet-1.id}"

  tags = {
    Name = "Prod-NAT-GW"
  }

  depends_on = [ aws_eip.elastic-ip-for-nat-gw ]
}

resource "aws_route" "nat-gw-route" {
  route_table_id            = "${aws_route_table.private-route-table.id}"
  nat_gateway_id            = "${aws_nat_gateway.nat-gw.id}"
  destination_cidr_block    = "0.0.0.0/0" #allow traffic from instances to outside world
}

resource "aws_internet_gateway" "revmonk-prod-igw" {
  vpc_id = "${aws_vpc.revmonk-prod-vpc.id}"

  tags = {
    Name = "revmonk-prod-IGW"
  }
}

resource "aws_route" "public-internet-gw-route" {
  route_table_id            = "${aws_route_table.public-route-table.id}"
  gateway_id                = "${aws_internet_gateway.revmonk-prod-igw.id}"
  destination_cidr_block    = "0.0.0.0/0"
}
