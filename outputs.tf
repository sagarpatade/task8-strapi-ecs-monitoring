# outputs.tf (Root Level)

output "strapi_admin_url" {
  description = "Click this link to access your highly secure Strapi deployment!"
  value       = "http://${module.alb.alb_dns_name}/admin"
}