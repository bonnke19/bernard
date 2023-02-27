# configuring our network for Tenacity IT

# creat a VPC

resource "aws_vpc" "Prod-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "Prod-VPC"
  }
}
  
# creating public subnet

resource "aws_subnet" "Prod-pub-sub-1" {
  vpc_id     = aws_vpc.Prod-VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Prod-pub-sub-1"
  }
}

resource "aws_subnet" "Prod-pub-sub-2" {
  vpc_id     = aws_vpc.Prod-VPC.id
  cidr_block = "10.0.2.0/24"
availability_zone = "eu-west-2a"

  tags = {
    Name = "Prod-pub-sub-2"
  }
}

# creating private subnet

resource "aws_subnet" "Prod-priv-sub-1" {
  vpc_id     = aws_vpc.Prod-VPC.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Prod-priv-sub-1"
  }
}

resource "aws_subnet" "Prod-priv-sub-2" {
  vpc_id     = aws_vpc.Prod-VPC.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Prod-priv-sub-2"
  }
}

# creating a public route table
resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id = aws_vpc.Prod-VPC.id
 

  tags = {
    Name = "Prod-pub-route-table"
  }
}

# Associate public subnets to route table
resource "aws_route_table_association" "public-sub-association1" {
  subnet_id = aws_subnet.Prod-pub-sub-1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

# Associate public subnets to route table
resource "aws_route_table_association" "public-sub-association2" {
  subnet_id = aws_subnet.Prod-pub-sub-2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

# creating a private route table
resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id = aws_vpc.Prod-VPC.id
 

  tags = {
    Name = "Prod-priv-route-table"
  }
}

# Associate private subnets to route table
resource "aws_route_table_association" "priv-sub-association-1" {
  subnet_id = aws_subnet.Prod-priv-sub-1.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

# Associate private subnets to route table
resource "aws_route_table_association" "priv-sub-association-2" {
  subnet_id = aws_subnet.Prod-priv-sub-2.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

# creating internet gateway
resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.Prod-VPC.id

  tags = {
    Name = "Prod-igw"
  }
}

# associate the IGW to the public subnets

resource "aws_route" "Prod-igw-association" {
 route_table_id = aws_route_table.Prod-pub-route-table.id
  gateway_id     = aws_internet_gateway.Prod-igw.id
  destination_cidr_block = "0.0.0.0/0"

}

# creating an elastic IP address
resource "aws_eip" "eip1" {
  vpc                       = true
}


# creating NAT gateway

resource "aws_nat_gateway" "Prod-Nat-gateway" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.Prod-pub-sub-1.id

  tags = {
    Name = "Prod-Nat-gateway"
  }
}

# associate NAT gateway to route table
resource "aws_route" "Prod-Nat-association" {
 route_table_id = aws_route_table.Prod-priv-route-table.id
  gateway_id     = aws_nat_gateway.Prod-Nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"

}