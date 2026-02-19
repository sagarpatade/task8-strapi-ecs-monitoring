# 1. Create a Subnet Group using your actual subnets
resource "aws_db_subnet_group" "strapi_db_group" {
  name       = "strapi-db-subnet-group"
  subnet_ids = ["subnet-03b215d73e25bf9d1", "subnet-0402e41a2030320e1"] 

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
