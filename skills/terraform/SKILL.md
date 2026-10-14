---
name: terraform
description: >-
  Evaluate Terraform deployments and runs through Terraform Cloud VCS-driven workflows rather than the
  local CLI. Load when working with Terraform configurations, plans, state, or deployment behavior.
---
# Terraform

- All Terraform deployments use Terraform Cloud with VCS-driven runs.
- Evaluate plan, apply, and deployment behavior in Terraform Cloud rather than in the local `terraform` CLI.
- When interacting with the Terraform Cloud or Terraform Enterprise API, load the `external-services` skill and authenticate with `TFE_TOKEN`.
