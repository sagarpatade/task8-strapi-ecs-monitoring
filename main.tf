# main.tf (Root Level)

# 1. Define the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# 2. Build the Network First
module "networking" {
  source = "./modules/networking"
}

# 3. Build Security Groups (Needs the VPC ID from the Network)
module "security" {
  source = "./modules/security"
  vpc_id = module.networking.vpc_id
}

# 4. Build the Load Balancer (Needs Public Subnets & ALB Security Group)
module "alb" {
  source         = "./modules/alb"
  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnet_ids
  alb_sg_id      = module.security.alb_sg_id
}

# 5. Build the Database (Needs Private Subnets & RDS Security Group)
module "rds" {
  source          = "./modules/rds"
  private_subnets = module.networking.private_subnet_ids
  rds_sg_id       = module.security.rds_sg_id
}

# 6. Build the ECS App (Needs Private Subnets, Target Group, and DB URL)
module "ecs" {
  source           = "./modules/ecs"
  private_subnets  = module.networking.private_subnet_ids
  ecs_sg_id        = module.security.ecs_sg_id
  target_group_arn = module.alb.target_group_arn
  
  # This is the magic! We pass the RDS URL directly into the Strapi container
  db_host          = module.rds.db_endpoint 
}