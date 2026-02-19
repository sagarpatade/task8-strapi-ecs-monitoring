# 1. Create a Subnet Group using your actual subnets
resource "aws_db_subnet_group" "strapi_db_group" {
  name       = "strapi-db-subnet-group-v2"
  # Use the first two subnet IDs to ensure we hit at least 2 AZs
  subnet_ids = [data.aws_subnets.all.ids[0], data.aws_subnets.all.ids[1]] 

  tags = {
    Name = "Strapi DB Subnet Group"
  }
}

# 2. Update the RDS instance to use this group
resource "aws_db_instance" "strapi_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "16.1"
  instance_class       = "db.t3.micro"
  db_name              = "strapidb"
  username             = "strapiuser"
  password             = "strapipassword123"
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true
  publicly_accessible  = true
  
  # This explicitly tells AWS which VPC/Subnets to use
  db_subnet_group_name = aws_db_subnet_group.strapi_db_group.name

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
}
