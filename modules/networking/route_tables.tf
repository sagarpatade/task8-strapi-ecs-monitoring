# modules/networking/route_tables.tf

# ------------------------------------------------------
# PUBLIC ROUTE TABLE (For ALB & NAT Gateway)
# ------------------------------------------------------
# This routes all outbound traffic to the existing Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw.id
  }

  tags = { Name = "sagar-public-rt" }
}

# Associate Public Subnets with the Public Route Table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------
# PRIVATE ROUTE TABLE (For ECS & RDS)
# ------------------------------------------------------
# This routes all outbound traffic to the NAT Gateway
# (Keeps things private, but allows pulling ECR images)
resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "sagar-private-rt" }
}

# Associate Private Subnets with the Private Route Table
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}