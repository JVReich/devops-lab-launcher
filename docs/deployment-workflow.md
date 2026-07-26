# Deployment Workflow

This project is designed as a parameterized DevOps lab launcher.

The goal is to provision a minimal AKS environment on demand, install a reusable platform baseline, and then deploy optional lab stacks through a common deployment mechanism.

## Deployment Layers

The project has three deployment layers:

```text
Bootstrap
→ Infrastructure
→ Stack Deployment
```

## 1. Bootstrap Layer

The bootstrap layer creates the Azure Storage backend used for Terraform remote state.

Path:

```text
infra/terraform/bootstrap
```

Responsibilities:

- Create the Terraform state resource group
- Create the Terraform state storage account
- Create the private blob container for state files
- Enable blob versioning and soft delete

The bootstrap layer is applied manually before the main environment Terraform configuration is migrated to remote state.

Example usage:

```powershell
cd infra/terraform/bootstrap

terraform init
terraform plan -out=tfplan
terraform apply tfplan

terraform output
```

After bootstrap completes, copy the `storage_account_name` output into:

```text
infra/terraform/environments/dev/backend.tf
```

Then initialize the dev environment backend:

```powershell
cd ../environments/dev
terraform init -migrate-state
```

The bootstrap state itself is local by design, because it manages the storage account that stores the rest of the project state.

## 2. Infrastructure Layer

The infrastructure layer creates and destroys the AKS lab environment.

Path:

```text
infra/terraform/environments/dev
```

Pipeline:

```text
.azuredevops/infra.yaml
```

Responsibilities:

- Run Terraform validate / plan / apply / destroy
- Create the resource group
- Create the virtual network and AKS subnet
- Create the AKS cluster
- Optionally install the platform baseline after AKS is created

The infrastructure pipeline supports these actions:

```text
validate
plan
apply
destroy
```

The infrastructure pipeline also includes this parameter:

```text
installPlatformBaseline
```

When `installPlatformBaseline` is enabled and the Terraform action is `apply`, the pipeline installs the platform baseline after AKS is created.

## 3. Platform Baseline

The platform baseline contains cluster-level components that should exist before optional lab stacks are deployed.

Current platform baseline:

```text
ingress-nginx
cert-manager
```

These are stored in the platform section of the deployment catalog:

```text
deployments/stacks.yaml
```

Their values files are located under:

```text
platform/
```

Current platform values paths:

```text
platform/ingress-nginx/values.yaml
platform/cert-manager/values.yaml
```

The infra pipeline installs them by calling the shared deployment script:

```powershell
./scripts/deploy-stack.ps1 -Type platform -Name ingress-nginx -Action deploy -Execute
./scripts/deploy-stack.ps1 -Type platform -Name cert-manager -Action deploy -Execute
```

Platform components are kept in the deployment catalog so the same deployment mechanism can be used locally and in pipelines.

## 4. Stack Deployment Layer

The stack deployment layer deploys optional lab workloads onto the AKS cluster.

Pipeline:

```text
.azuredevops/deploy-stack.yaml
```

Script:

```text
scripts/deploy-stack.ps1
```

Catalog:

```text
deployments/stacks.yaml
```

Values files:

```text
stacks/
```

Supported stack actions:

```text
deploy
status
uninstall
```

Current optional stacks:

```text
nginx
redis
prometheus-grafana
argocd
elk
```

Example dry-run:

```powershell
./scripts/deploy-stack.ps1 -Type stack -Name redis -Action deploy
```

Example real deployment:

```powershell
./scripts/deploy-stack.ps1 -Type stack -Name redis -Action deploy -Execute
```

Example status check:

```powershell
./scripts/deploy-stack.ps1 -Type stack -Name redis -Action status -Execute
```

Example uninstall:

```powershell
./scripts/deploy-stack.ps1 -Type stack -Name redis -Action uninstall -Execute
```

## Local Workflow

A typical local test workflow is:

```powershell
cd infra/terraform/environments/dev

terraform plan -out=tfplan
terraform apply tfplan
```

Connect to AKS:

```powershell
az aks get-credentials `
  --resource-group rg-devops-lab-dev-ilc `
  --name aks-devops-lab-dev-ilc `
  --overwrite-existing

kubectl get nodes
```

Install platform baseline:

```powershell
cd C:\repos\devops-lab-launcher

./scripts/deploy-stack.ps1 -Type platform -Name ingress-nginx -Action deploy -Execute
./scripts/deploy-stack.ps1 -Type platform -Name cert-manager -Action deploy -Execute
```

Deploy an optional stack:

```powershell
./scripts/deploy-stack.ps1 -Type stack -Name redis -Action deploy -Execute
```

Destroy the lab when finished:

```powershell
cd infra/terraform/environments/dev

terraform destroy
```

## Azure DevOps Workflow

The intended Azure DevOps workflow is:

```text
1. Run infra.yaml with action: plan
2. Review Terraform output
3. Run infra.yaml with action: apply
4. Allow infra.yaml to install the platform baseline
5. Run deploy-stack.yaml to deploy optional stacks
6. Run deploy-stack.yaml to uninstall optional stacks when finished
7. Run infra.yaml with action: destroy to remove the AKS lab
```

The infra pipeline should be used for Azure infrastructure lifecycle.

The deploy-stack pipeline should be used for optional workload lifecycle.

## Responsibility Boundaries

### Bootstrap

Owns:

```text
Terraform remote state storage
```

Does not own:

```text
AKS
lab stacks
platform components
```

### Infrastructure

Owns:

```text
Resource group
Virtual network
AKS subnet
AKS cluster
Platform baseline installation trigger
```

Does not own:

```text
Optional stack lifecycle
Application code build/deploy
```

### Platform Baseline

Owns:

```text
Ingress controller
Certificate manager
Cluster-level prerequisites
```

Does not own:

```text
Redis
ArgoCD
Monitoring
ELK
Demo workloads
```

### Stack Deployment

Owns:

```text
Optional lab stacks
Helm-based stack deployment
Stack status checks
Stack uninstall
```

Does not own:

```text
Azure infrastructure creation
AKS cluster creation
Remote state bootstrap
```

## Current Tested Milestones

The following have been tested locally:

```text
AKS cluster creation with Terraform
kubectl access to AKS
ingress-nginx deployment
cert-manager deployment
Redis deployment
Redis uninstall
ArgoCD deployment
Terraform destroy
```

## Cost Model

The project is designed to avoid ongoing cost.

Expected lifecycle:

```text
Create AKS
Deploy platform baseline
Deploy selected stacks
Test/demo
Destroy AKS
```

The Terraform remote state storage account is expected to remain running and should cost very little because it only stores Terraform state.

The AKS node is the main cost driver and should be destroyed when not actively testing.

## Notes

Do not commit local Terraform runtime files:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
tfplan
terraform.tfvars
terraform.auto.tfvars.json
```

Commit only reusable code, configuration, documentation, examples, and pipeline YAML.