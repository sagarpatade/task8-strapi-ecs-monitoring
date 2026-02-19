output "rds_endpoint" {
  value = aws_db_instance.strapi_db.endpoint
}

output "rds_hostname" {
  value = aws_db_instance.strapi_db.address
}

output "ecs_service_name" {
  # Updated from 'strapi_service' to 'main' to match main.tf
  value = aws_ecs_service.main.name
}
