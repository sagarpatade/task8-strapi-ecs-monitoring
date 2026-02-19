output "rds_endpoint" {
  value = aws_db_instance.strapi_db.endpoint
}

output "ecs_service_name" {
  value = aws_ecs_service.strapi_service.name
}