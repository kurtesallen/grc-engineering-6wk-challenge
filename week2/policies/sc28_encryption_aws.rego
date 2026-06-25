package compliance.sc28_aws

# METADATA
# title: SC-28 - Encryption at Rest (AWS S3)

# Collect all S3 buckets from planned values
buckets[b] {
    b := input.planned_values.root_module.resources[_]
    b.type == "aws_s3_bucket"
}

# Collect all encryption configuration references
encryption_bucket_refs[ref] {
    enc := input.planned_values.root_module.resources[_]
    enc.type == "aws_s3_bucket_server_side_encryption_configuration"
    ref := enc.values.bucket
}

# Terraform address helper
bucket_addr(b) = addr {
    addr := b.address
}

# A bucket is encrypted if its address appears in encryption refs
bucket_encrypted(b) {
    encryption_bucket_refs[bucket_addr(b)]
}

# Deny unencrypted buckets
deny[msg] {
    b := buckets[_]
    not bucket_encrypted(b)

    msg := sprintf(
        "Bucket %s is missing server-side encryption configuration",
        [bucket_addr(b)]
    )
}
