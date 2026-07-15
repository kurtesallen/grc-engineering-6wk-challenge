resource "aws_cloudtrail" "main" {
  depends_on = [
    aws_s3_bucket_policy.logs
  ]

  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
}


