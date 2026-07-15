terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "cloudtrail" {
  source      = "./cloudtrail"
  bucket_name = var.bucket_name
  trail_name  = var.trail_name
}

module "securityhub" {
  source = "./securityhub"

  enable_security_hub = true
  region              = var.region
}
