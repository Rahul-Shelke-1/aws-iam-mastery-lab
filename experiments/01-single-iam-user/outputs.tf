output "iam_user_name" {
  description = "IAM user name."
  value       = aws_iam_user.developer.name
}

output "iam_user_arn" {
  description = "ARN of the IAM user."
  value       = aws_iam_user.developer.arn
}

output "iam_user_unique_id" {
  description = "AWS-generated unique identifier for the IAM user."
  value       = aws_iam_user.developer.unique_id
}

output "iam_user_path" {
  description = "Path assigned to the IAM user."
  value       = aws_iam_user.developer.path
}