resource "aws_iam_access_key" "developer" {
  user = var.iam_user_name
}