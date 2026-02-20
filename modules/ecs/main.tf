# modules/ecs/main.tf

variable "private_subnets" { type = list(string) }
variable "ecs_sg_id" { type = string }
variable "target_group_arn" { type = string }
variable "db_host" { 
  description = "The database endpoint (will be passed from RDS module later)"
  type        = string 
}


# 2. The ECS Cluster
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-production-cluster"
}

# 3. The Task Definition (Your 1024 CPU / 2048 Memory fix is here!)
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-production-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = "arn:aws:iam::811738710312:role/ecs_fargate_taskRole"

  container_definitions = jsonencode([
    {
      name      = "strapi-app"
      image     = "811738710312.dkr.ecr.us-east-1.amazonaws.com/sagar-patade-strapi-app:latest"
      cpu       = 1024
      memory    = 2048
      essential = true
      
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
          protocol      = "tcp"
        }
      ]
      
      # We pass the DB host dynamically so Strapi knows where to connect
      environment = [
        { name = "DATABASE_HOST", value = var.db_host },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "DATABASE_NAME", value = "strapi" },
        { name = "DATABASE_USERNAME", value = "postgres" },
        { name = "DATABASE_PASSWORD", value = "strapi1234" } # Update this in production!
      ]
    }
  ])
}

# 4. The ECS Service (Deploying inside the Private Subnets)
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-production-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false # Security Upgrade: Completely hidden from the internet
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "strapi-app"
    container_port   = 1337
  }
}