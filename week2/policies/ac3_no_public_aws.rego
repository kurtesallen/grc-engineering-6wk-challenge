package compliance.ac3_aws

# METADATA
# title: AC-3 - Access Enforcement (AWS S3 public access block)

# Collect all S3 buckets
buckets[b] {
    b := input.configuration.root_module.resources[_]
    b.type == "aws_s3_bucket"
}

# Terraform bucket address helper
bucket_addr(b) = addr {
    addr := sprintf("aws_s3_bucket.%s.id", [b.name])
}

# Collect PAB configs
pab_configs[p] {
    p := input.configuration.root_module.resources[_]
    p.type == "aws_s3_bucket_public_access_block"
}

# Find PAB config referencing the bucket
pab_for_bucket(bucket_ref) = pab {
    pab := pab_configs[_]
    refs := pab.expressions.bucket.references
    some r
    refs[r] == bucket_ref
}

# PAB planned-values address helper
pab_planned_addr(p) = addr {
    addr := sprintf("aws_s3_bucket_public_access_block.%s", [p.name])
}

# Lookup planned resource by address
planned_resource(addr) = res {
    res := input.planned_values.root_module.resources[_]
    res.address == addr
}

# Validate flags
pab_flags_all_true(vals) {
    vals.block_public_acls == true
    vals.block_public_policy == true
    vals.ignore_public_acls == true
    vals.restrict_public_buckets == true
}

# ❌ Deny incorrect flags
deny[msg] {
    b := buckets[_]
    bucket_ref := bucket_addr(b)

    pab := pab_for_bucket(bucket_ref)
    pr := planned_resource(pab_planned_addr(pab))
    vals := pr.values

    not pab_flags_all_true(vals)

    msg := sprintf(
        "Bucket %s has a public access block with one or more flags not set to true",
        [bucket_ref]
    )
}

# ❌ Deny missing PAB
deny[msg] {
    b := buckets[_]
    bucket_ref := bucket_addr(b)

    not pab_for_bucket(bucket_ref)

    msg := sprintf(
        "Bucket %s is missing aws_s3_bucket_public_access_block",
        [bucket_ref]
    )
}
