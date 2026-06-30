# AKS DevOps Lab Launcher

A reusable Azure/Kubernetes lab platform for deploying common DevOps interview/demo stacks on demand.

The goal of this project is not to build complex applications, but to demonstrate a modern DevOps workflow:

- Infrastructure as Code with Terraform
- Azure Kubernetes Service
- Modular Terraform structure
- Azure Pipelines CI/CD
- Helm-based application/platform deployments
- DNS/TLS/Ingress-based exposure
- Cost-conscious ephemeral lab environments

## Planned Workflow

```text
Run pipeline manually
↓
Choose action: validate / plan / apply / destroy
↓
Choose environment: dev
↓
Terraform provisions Azure infrastructure
↓
AKS cluster is created or updated
↓
Selected platform components and stacks are deployed
↓
Service is exposed on a subdomain