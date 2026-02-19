provider "aws" {
  region = "us-east-1"
}

# 1. Data Sources for Networking
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_caller_identity" "current" {}

# 2. CloudWatch Log Group for Task 8 Monitoring
resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/strapi-task8-1714"
  retention_in_days = 7
}

# 3. Security Group for ECS
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg-task8-1714"
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

# 4. ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "strapi-cluster-task8"
}

# 5. ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ec2-ecr-role"
  task_role_arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ec2-ecr-role"

  container_definitions = jsonencode([{
    name      = "strapi-container"
    image     = "sagar-patade-strapi-app:latest"
    essential = true
    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/strapi-task8-1714"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# 6. ECS Service (This is the resource Terraform was missing!)
resource "aws_ecs_service" "main" {
  name            = "strapi-service-1714"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.all.ids
    security_groups  = [aws_security_group.strapi_sg.id]
    assign_public_ip = true
  }
}


