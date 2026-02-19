# RDS SECURITY GROUP
resource "aws_security_group" "rds_sg" {
  name        = "strapi-rds-sg"
  vpc_id      = data.aws_vpc.default.id
  description = "Allow Strapi Tasks to access PostgreSQL"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.strapi_sg.id]
  }
}

# RDS POSTGRES INSTANCE
resource "aws_db_instance" "strapi_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.1"
  instance_class         = "db.t3.micro"
  db_name                = "strapi"
  username               = "strapi_user"
  password               = "SagarStrapiPass123"
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}