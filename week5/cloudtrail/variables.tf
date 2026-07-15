variable "bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
}

variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}
