provider "aws" {
  region = "us-east-1"
}

# 1. Data Sources
data "aws_vpc" "default" { default = true }

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_caller_identity" "current" {}

# 2. Monitoring (Use v7 to avoid conflicts)
resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/strapi-task8-v9"
  retention_in_days = 7
}

# 3. Security Group
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg-task8-v9"
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

# 4. Cluster
resource "aws_ecs_cluster" "main" {
  name = "strapi-cluster-task8-v9"
}

# 5. Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "strapi-task-v9"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  # Using the company role directly
  execution_role_arn       = "arn:aws:iam::811738710312:role/ecs_fargate_taskRole"
  task_role_arn            = "arn:aws:iam::811738710312:role/ecs_fargate_taskRole"

  container_definitions = jsonencode([{
    name      = "strapi-container"
    image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/sagar-patade-strapi-app:latest"
    essential = true
    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/strapi-task8-v9"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# 6. Service
resource "aws_ecs_service" "main" {
  name            = "strapi-service-v9"
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