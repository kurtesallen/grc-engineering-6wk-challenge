variable "region" {
  type        = string
  description = "AWS region for CloudTrail and Security Hub"
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket used for CloudTrail log storage"
}

variable "trail_name" {
  type        = string
  description = "Name of the CloudTrail trail"
}
