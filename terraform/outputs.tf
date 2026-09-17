output "service_url" {
  description = "Public URL of the App Runner service (use /sub for subscription)"
  value       = "https://${aws_apprunner_service.nodejs_argo.service_url}"
}

output "service_arn" {
  description = "ARN of the App Runner service"
  value       = aws_apprunner_service.nodejs_argo.arn
}

output "service_id" {
  description = "ID of the App Runner service"
  value       = aws_apprunner_service.nodejs_argo.service_id
}

output "subscription_url" {
  description = "Full subscription URL"
  value       = "https://${aws_apprunner_service.nodejs_argo.service_url}/${var.sub_path}"
}
