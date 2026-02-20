# modules/rds/outputs.tf

output "db_endpoint" {
  description = "The database URL/address to pass to the Strapi containers"
  value       = aws_db_instance.strapi_db.address
}