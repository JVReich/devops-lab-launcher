# Local Development

This document explains how to work with the AKS DevOps Lab Launcher repository locally.

## Prerequisites

Recommended tools:

- Git
- VS Code
- Terraform
- Azure CLI
- PowerShell 7+
- Helm
- kubectl

Azure access is only required for `terraform plan`, `terraform apply`, and live Kubernetes deployments.

## Repository Layout

```text
.
├── .azuredevops/
├── deployments/
├── docs/
├── infra/
├── platform/
├── scripts/
├── stacks/
└── website/