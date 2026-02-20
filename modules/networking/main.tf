# modules/networking/main.tf

# 1. USE EXISTING VPC
data "aws_vpc" "main" {
  id = "vpc-091cb9c5df7bd2971"
}

# 2. USE EXISTING INTERNET GATEWAY
data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# 3. Create Public Subnets
resource "aws_subnet" "public_1" {
  vpc_id                  = data.aws_vpc.main.id 
  cidr_block              = "10.0.211.0/24"      
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "sagar-public-us-east-1a" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = data.aws_vpc.main.id
  cidr_block              = "10.0.212.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "sagar-public-us-east-1b" }
}

# 4. Create Private Subnets
resource "aws_subnet" "private_1" {
  vpc_id            = data.aws_vpc.main.id
  cidr_block        = "10.0.213.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "sagar-private-us-east-1a" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = data.aws_vpc.main.id
  cidr_block        = "10.0.214.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "sagar-private-us-east-1b" }
}

# 5. NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  tags = { Name = "sagar-nat-gw" }
}