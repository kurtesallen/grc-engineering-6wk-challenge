package compliance.cm6_aws

required := {"Project", "Environment", "ManagedBy", "ComplianceScope"}

# All resources
resources[r] {
    r := input.planned_values.root_module.resources[_]
}

# Effective tags
effective_tags(r) = tags {
    tags := r.values.tags_all
} else = tags {
    tags := r.values.tags
}

# Missing required tags
missing_required_tags(r) = missing {
    tags := effective_tags(r)
    missing := {k |
        required[k]
        not tags[k]
    }
}

# Deny resources missing tags
deny[msg] {
    r := resources[_]
    missing := missing_required_tags(r)
    count(missing) > 0

    msg := sprintf(
        "Resource %s is missing required tags: %v",
        [r.address, missing]
    )
}
