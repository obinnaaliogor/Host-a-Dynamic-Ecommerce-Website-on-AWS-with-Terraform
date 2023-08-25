#1 create vpc
# terraform aws create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr #"10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "dev-vpc"
  }
}

#2 create internet gateway and attach it to vpc
# terraform aws create internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}

#3 create public subnet az1
# terraform aws create subnet
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_az1_cidr_block #"10.0.0.0/24"
  availability_zone       = var.availability_zones[0]        #"us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public subnet az1"
  }
}

#4 create public subnet az2
# terraform aws create subnet
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_az2_cidr_block #"10.0.1.0/24"
  availability_zone       = var.availability_zones[1]        #"us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public subnet az2"
  }
}

#5 create route table and add public route
# terraform aws create route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public route table"
  }
}

#6 associate public subnet az1 to "public route table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public_subnet_az1_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_route_table.id
}

#7 associate public subnet az2 to "public route table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public_subnet_az2_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_route_table.id
}

##################################
#8 create private app subnet az1
# terraform aws create subnet
resource "aws_subnet" "private_app_subnet_az1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_app_subnet_az1_cidr_block #"10.0.2.0/24"
  availability_zone       = var.availability_zones[0]             #"us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private app subnet az1"
  }
}

#9 create private app subnet az2
# terraform aws create subnet
resource "aws_subnet" "private_app_subnet_az2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_app_subnet_az2_cidr_block #"10.0.3.0/24"
  availability_zone       = var.availability_zones[1]             #"us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private app subnet az2"
  }
}

#10 create private data subnet az1
# terraform aws create subnet
resource "aws_subnet" "private_data_subnet_az1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_data_subnet_az1_cidr_block #"10.0.4.0/24"
  availability_zone       = var.availability_zones[0]              #"us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private data subnet az1"
  }
}

# 11create private data subnet az2
# terraform aws create subnet
resource "aws_subnet" "private_data_subnet_az2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_data_subnet_az2_cidr_block #"10.0.5.0/24"
  availability_zone       = var.availability_zones[1]              #"us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private data subnet az2"
  }
}

#12 Create a Nat Gateway to allow resources in the private subnet to access the internet securely.

# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az1
# terraform aws allocate elastic ip
resource "aws_eip" "eip_for_nat_gateway_az1" {
  #vpc    = true #aws_vpc.vpc.id dont make this mistake this only requires a bool
  domain = "vpc"

  tags = {
    Name = "EIP for Nat Gateway az1"
  }
}

#13 allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az2
# terraform aws allocate elastic ip
resource "aws_eip" "eip_for_nat_gateway_az2" {
  #vpc    = true
  domain = "vpc"

  tags = {
    Name = "EIP for Nat Gateway az2"
  }
}

#14 create nat gateway in public subnet az1
# terraform create aws nat gateway
resource "aws_nat_gateway" "nat_gateway_az1" {
  allocation_id = aws_eip.eip_for_nat_gateway_az1.id
  subnet_id     = aws_subnet.public_subnet_az1.id

  tags = {
    Name = "Nat Gateway az1"
  }

  #15 to ensure proper ordering, it is recommended to add an explicit dependency
  # on the internet gateway for the vpc.
  depends_on = [aws_subnet.public_subnet_az1]
}

#16 create nat gateway in public subnet az2
# terraform create aws nat gateway
resource "aws_nat_gateway" "nat_gateway_az2" {
  allocation_id = aws_eip.eip_for_nat_gateway_az2.id
  subnet_id     = aws_subnet.public_subnet_az2.id

  tags = {
    Name = "Nat Gateway az2"
  }

  #17 to ensure proper ordering, it is recommended to add an explicit dependency
  # on the internet gateway for the vpc.
  depends_on = [aws_subnet.public_subnet_az2]
}

#18 create private route table az1 and add route through nat gateway az1
# terraform aws create route table
resource "aws_route_table" "private_route_table_az1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az1.id
  }

  tags = {
    Name = "private route table az1"
  }
}

#19 associate private app subnet az1 with private route table az1
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private_app_subnet_az1_route_table_az1_association" {
  subnet_id      = aws_subnet.private_app_subnet_az1.id
  route_table_id = aws_route_table.private_route_table_az1.id
}

#20 associate private data subnet az1 with private route table az1
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private_data_subnet_az1_route_table_az1_association" {
  subnet_id      = aws_subnet.private_data_subnet_az1.id
  route_table_id = aws_route_table.private_route_table_az1.id
}

#21 create private route table az2 and add route through nat gateway az2
# terraform aws create route table
resource "aws_route_table" "private_route_table_az2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az2.id
  }

  tags = {
    Name = "private route table az2"
  }
}

#22 associate private app subnet az2 with private route table az2
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private_app_subnet_az2_route_table_az2_association" {
  subnet_id      = aws_subnet.private_app_subnet_az2.id
  route_table_id = aws_route_table.private_route_table_az2.id
}

#23 associate private data subnet az2 with private route table az2
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private_data_subnet_az2_route_table_az2_association" {
  subnet_id      = aws_subnet.private_data_subnet_az2.id
  route_table_id = aws_route_table.private_route_table_az2.id
}