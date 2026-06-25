package compliance.sc28_aws_test

import data.compliance.sc28_aws

test_compliant_bucket_passes {
    results := sc28_aws.deny with input as input_good
    count(results) == 0
}

test_unencrypted_bucket_denied {
    results := sc28_aws.deny with input as input_bad
    count(results) == 1
}

# Compliant bucket: has an SSE configuration referencing the bucket
input_good = {
  "planned_values": {
    "root_module": {
      "resources": [
        {
          "address": "aws_s3_bucket.primary",
          "type": "aws_s3_bucket",
          "values": {}
        },
        {
          "address": "aws_s3_bucket_server_side_encryption_configuration.primary",
          "type": "aws_s3_bucket_server_side_encryption_configuration",
          "values": {
            "bucket": "aws_s3_bucket.primary"
          }
        }
      ]
    }
  }
}

# Non‑compliant bucket: no SSE configuration
input_bad = {
  "planned_values": {
    "root_module": {
      "resources": [
        {
          "address": "aws_s3_bucket.primary",
          "type": "aws_s3_bucket",
          "values": {}
        }
      ]
    }
  }
}
