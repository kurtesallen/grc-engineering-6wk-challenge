package compliance.ac3_aws_test

import data.compliance.ac3_aws

test_complete_pab_passes {
    results := ac3_aws.deny with input as input_complete
    count(results) == 0
}

test_missing_pab_denied {
    results := ac3_aws.deny with input as input_missing
    count(results) == 1
}

input_complete = {
  "configuration": {
    "root_module": {
      "resources": [
        {
          "type": "aws_s3_bucket",
          "name": "primary"
        },
        {
          "type": "aws_s3_bucket_public_access_block",
          "name": "primary",
          "expressions": {
            "bucket": {
              "references": ["aws_s3_bucket.primary.id"]
            }
          }
        }
      ]
    }
  },
  "planned_values": {
    "root_module": {
      "resources": [
        {
          "address": "aws_s3_bucket_public_access_block.primary",
          "values": {
            "block_public_acls": true,
            "block_public_policy": true,
            "ignore_public_acls": true,
            "restrict_public_buckets": true
          }
        }
      ]
    }
  }
}

input_missing = {
  "configuration": {
    "root_module": {
      "resources": [
        {
          "type": "aws_s3_bucket",
          "name": "primary"
        }
      ]
    }
  },
  "planned_values": {
    "root_module": {
      "resources": []
    }
  }
}
