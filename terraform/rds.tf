resource "aws_db_subnet_group" "strapi_db_group" {
  name       = "strapi-db-subnet-group-final"
  # Using all discovered IDs ensures we meet the 2+ AZ requirement
  subnet_ids = data.aws_subnets.all.ids 

  tags = {
    Name = "Strapi DB Subnet Group"
  }
}

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
  db_subnet_group_name = aws_db_subnet_group.strapi_db_group.name
  publicly_accessible  = true
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
}
