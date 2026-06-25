package compliance.cm6_aws_test

import data.compliance.cm6_aws

test_all_tags_present_passes {
    results := cm6_aws.deny with input as input_good
    count(results) == 0
}

test_missing_tags_denied {
    results := cm6_aws.deny with input as input_bad
    count(results) == 1
}

input_good = {
  "planned_values": {
    "root_module": {
      "resources": [
        {
          "address": "aws_s3_bucket.primary",
          "values": {
            "tags_all": {
              "Project": "X",
              "Environment": "dev",
              "ManagedBy": "terraform",
              "ComplianceScope": "full"
            }
          }
        }
      ]
    }
  }
}

input_bad = {
  "planned_values": {
    "root_module": {
      "resources": [
        {
          "address": "aws_s3_bucket.primary",
          "values": {
            "tags_all": {"Project": "X"}
          }
        }
      ]
    }
  }
}
