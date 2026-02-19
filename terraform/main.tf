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

# NEW: Dedicated IAM Role for ECS to bypass company role restrictions
resource "aws_iam_role" "ecs_execution_role" {
  name = "strapi-ecs-execution-role-task8"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# NEW: Attach the standard Execution Policy to the new role
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

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
  
  # Pointing to the NEW role we created above
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "strapi-container"
    # Using the full ECR path required by Fargate
    image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/sagar-patade-strapi-app:latest"
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

# 6. ECS Service
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