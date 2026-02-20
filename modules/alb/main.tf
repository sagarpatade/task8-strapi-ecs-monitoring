# modules/alb/main.tf

variable "vpc_id" { type = string }
variable "public_subnets" { type = list(string) }
variable "alb_sg_id" { type = string }

# 1. The Load Balancer itself (Internet Facing)
resource "aws_lb" "main" {
  name               = "sagar-strapi-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  tags = { Name = "strapi-production-alb" }
}

# 2. The Target Group (Where the ALB sends the traffic)
resource "aws_lb_target_group" "strapi_tg" {
  name        = "sagar-strapi-tg"
  port        = 1337 # Strapi's port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Required for Fargate

  health_check {
    path                = "/_health" # Strapi's default health check endpoint
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200,204"  # Strapi sometimes returns 204
  }
}

# 3. The Listener (The rule that catches Port 80 and forwards it)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg.arn
  }
}