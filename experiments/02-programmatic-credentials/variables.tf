variable "aws_region" {
  description = "AWS region for this experiment."
  type        = string
  default     = "ap-south-1"
}

variable "iam_user_name" {
  description = "Existing IAm user receiving the access key"
  type        = string
  default     = "developer-alice"
}