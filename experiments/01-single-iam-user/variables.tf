variable "aws_region" {
  description = "AWS region used by the provider configuration."
  type        = string
  default     = "ap-south-1"
}

variable "iam_user_name" {
  description = "Name of the IAM user to create."
  type        = string
  default     = "developer-alice"

  validation {
    condition = (
      length(var.iam_user_name) >= 1 &&
      length(var.iam_user_name) <= 64
    )

    error_message = "IAM user name must be between 1 and 64 characters."
  }
}

variable "iam_user_path" {
  description = "IAM path assigned to the user."
  type        = string
  default     = "/developers/"
}

variable "project_name" {
  description = "Project name used for resource tagging."
  type        = string
  default     = "aws-iam-mastery-lab"
}

variable "environment" {
  description = "Environment associated with this experiment."
  type        = string
  default     = "sandbox"
}
