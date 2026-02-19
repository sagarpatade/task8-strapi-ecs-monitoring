provider "aws" {
  region = "us-east-1"
}

# This is the "missing" declaration
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/strapi-task8-final"
  retention_in_days = 7
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg-task8-final"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster and Task Definition code follows here...
