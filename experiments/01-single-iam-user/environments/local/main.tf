resource "aws_iam_user" "developer" {
  name = var.iam_user_name
  path = var.iam_user_path

  tags = {
    Name        = var.iam_user_name
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Experiment  = "01-single-iam-user"
    Purpose     = "IAM learning experiment"
  }
}