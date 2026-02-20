# modules/rds/main.tf

variable "private_subnets" { type = list(string) }
variable "rds_sg_id" { type = string }

# 1. Database Subnet Group
# This forces the RDS instance to ONLY launch inside our private subnets
resource "aws_db_subnet_group" "strapi_db_subnet_group" {
  name       = "strapi-production-db-subnet-group"
  subnet_ids = var.private_subnets
  tags       = { Name = "strapi-private-db-subnet" }
}

# 2. The PostgreSQL Database
resource "aws_db_instance" "strapi_db" {
  identifier             = "strapi-production-db"
  engine                 = "postgres"
  engine_version         = "16" # The exact version you used yesterday
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  
  db_name                = "strapi"
  username               = "postgres"
  password               = "strapi1234" # For production, you'd use AWS Secrets Manager!
  
  db_subnet_group_name   = aws_db_subnet_group.strapi_db_subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id]
  
  publicly_accessible    = false # Security Upgrade: Completely invisible to the internet
  skip_final_snapshot    = true  # Allows 'terraform destroy' to run quickly without hanging
}