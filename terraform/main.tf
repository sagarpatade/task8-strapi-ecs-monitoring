# NETWORK DATA
data "aws_vpc" "default" { default = true }

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# CLOUDWATCH LOGGING
resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/strapi"
  retention_in_days = 7
}

# ECS CLUSTER WITH METRICS
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-monitoring-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# SECURITY GROUP FOR STRAPI
resource "aws_security_group" "strapi_sg" {
  name   = "strapi-sg-task8"
  vpc_id = data.aws_vpc.default.id

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

# ECS TASK DEFINITION
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-v8-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512" # Increased for RDS connection stability
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::811738710312:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::811738710312:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "strapi-container"
      image     = "811738710312.dkr.ecr.us-east-1.amazonaws.com/sagar-patade-strapi-app:${var.image_tag}"
      essential = true
      portMappings = [{ containerPort = 1337, hostPort = 1337 }]
      
      environment = [
        { name = "DATABASE_CLIENT",   value = "postgres" },
        { name = "DATABASE_HOST",     value = aws_db_instance.strapi_db.address },
        { name = "DATABASE_PORT",     value = "5432" },
        { name = "DATABASE_NAME",     value = aws_db_instance.strapi_db.db_name },
        { name = "DATABASE_USERNAME", value = aws_db_instance.strapi_db.username },
        { name = "DATABASE_PASSWORD", value = aws_db_instance.strapi_db.password },
        { name = "NODE_ENV",          value = "production" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.strapi_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS SERVICE
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service-task8"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.public.ids
    security_groups  = [aws_security_group.strapi_sg.id]
    assign_public_ip = true
  }
}