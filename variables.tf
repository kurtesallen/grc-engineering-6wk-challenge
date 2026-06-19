# -----------------------------------------------------------------------------
# Input Variables
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project used for tagging and bucket naming."
  type        = string

  validation {
    condition     = length(var.project_name) > 0
    error_message = "project_name cannot be empty."
  }
}

variable "environment" {
  description = "Deployment environment (e.g., dev, test, prod, sandbox)."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod", "sandbox"], var.environment)
    error_message = "environment must be one of: dev, test, prod, sandbox."
  }
}

variable "region" {
  description = "AWS region where resources will be deployed."
  type        = string

  validation {
    condition     = length(var.region) > 0
    error_message = "region cannot be empty."
  }
}
