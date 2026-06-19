# Week 1 — Deploying Your First Compliant Cloud Resource

This repository contains the Week 1 build of the GRC Engineering challenge: deploying a fully compliant AWS S3 resource using Terraform and generating machine‑readable evidence that proves control enforcement.

The module implements four NIST 800‑53 controls using Infrastructure‑as‑Code.

---

## Controls Implemented

### **SC‑28 — Protection of Information at Rest**
- AES‑256 server‑side encryption enabled on both the primary bucket and the log bucket.

### **AC‑3 — Access Enforcement**
- All four S3 public access block settings enabled on both buckets.

### **CM‑6 — Configuration Settings**
- Versioning enabled on the primary bucket.
- Provider‑level default tags applied consistently.

### **AU‑3 / AU‑6 — Audit Logging**
- Ownership controls and log‑delivery ACL applied to the log bucket.
- Primary bucket configured to deliver access logs to the log bucket.

---

## Repository Structure

.
├── main.tf
├── variables.tf
├── outputs.tf
├── verify.sh
├── evidence/
│   └── plan.json
└── README.md


- **main.tf** — Terraform configuration implementing all controls  
- **variables.tf** — validated input variables  
- **outputs.tf** — self‑attesting evidence outputs  
- **verify.sh** — script to validate encryption, versioning, and public access settings  
- **evidence/plan.json** — machine‑readable proof generated from `terraform show -json`

---

## Generating Evidence

Run the following commands:

```bash
- terraform init
- terraform plan -out=tfplan
- terraform show -json tfplan > evidence/plan.json

## Verification

- ./verify.sh

- This script confirms:

- AES‑256 encryption

- Versioning enabled

- All public access block flags set to true

## Purpose
- This project demonstrates how compliance can be enforced and proven directly through code — a foundational skill in modern GRC engineering and the basis for the Weeks 2–6 builds.