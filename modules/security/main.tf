# modules/security/main.tf

variable "vpc_id" {
  description = "The ID of the VPC created in the networking module"
  type        = string
}

# 1. ALB Security Group (Public Facing)
resource "aws_security_group" "alb_sg" {
  name        = "sagar-strapi-alb-sg-v2"
  description = "Allow HTTP traffic from the internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the world
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. ECS Security Group (Private App Layer)
resource "aws_security_group" "ecs_sg-v2" {
  name        = "sagar-strapi-ecs-sg"
  description = "Allow traffic from ALB to Strapi"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Chain of Trust Step 1
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Needs outbound to pull the ECR image via NAT
  }
}

# 3. RDS Security Group (Private Data Layer)
resource "aws_security_group" "rds_sg-v2" {
  name        = "sagar-strapi-rds-sg"
  description = "Allow traffic from ECS to Database"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id] # Chain of Trust Step 2
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}