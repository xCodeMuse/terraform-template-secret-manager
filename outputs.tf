output "secret_name" {
  description = "The Name of the secret managers"
  value       = {for key, secrets_manager in aws_secretsmanager_secret.sm : key => secrets_manager.name}
}


output "secret_arn" {
  description = "The ARN of the secret managers"
  value       = {for key, secrets_manager in aws_secretsmanager_secret.sm : key => secrets_manager.arn}
}

output "secret_id" {
  description = "The ID of the secret"
  value       = {for key, secrets_manager in aws_secretsmanager_secret.sm : key => secrets_manager.id}
}