output "access_key_id" {
  description = "Access key ID for developer-alice."
  value       = aws_iam_access_key.developer.id
}

output "secret_access_key" {
  description = "Secret access key for developer-alice."
  value       = aws_iam_access_key.developer.secret
  sensitive   = true
}