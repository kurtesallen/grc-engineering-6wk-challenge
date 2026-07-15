locals {
  nist_standard_arn = "arn:aws:securityhub:${var.region}::standards/nist-800-53/v5"
}

resource "aws_securityhub_standards_subscription" "nist" {
  standards_arn = "arn:aws:securityhub:${var.region}::standards/nist-800-53/v/5.0.0"
}

output "nist_standard_arn" {
  value = local.nist_standard_arn
}

