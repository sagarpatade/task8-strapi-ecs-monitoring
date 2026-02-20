# modules/ecs/outputs.tf

output "cluster_name" {
  value = aws_ecs_cluster.strapi_cluster.name
}

output "service_name" {
  value = aws_ecs_service.strapi_service.name
}