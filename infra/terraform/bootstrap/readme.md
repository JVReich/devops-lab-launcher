# Terraform Remote State Bootstrap

This directory creates the Azure Storage backend used for Terraform remote state.

The bootstrap layer should be applied before running the main environment Terraform configuration in:

```text
infra/terraform/environments/dev
```

## Purpose

Terraform needs the remote backend storage account to exist before it can store state there.

Because of that, the remote state backend is created by a small separate Terraform configuration.

```text
bootstrap
→ creates remote state storage
→ environment Terraform uses that storage
```

## Resources Created

This bootstrap configuration creates:

```text
Resource group
Storage account
Private blob container
```

The storage account is configured for:

```text
Standard LRS replication
Private container access
Minimum TLS 1.2
Blob versioning
Blob soft delete
Container soft delete
```

## Expected Resource Names

Resource group:

```text
rg-devops-lab-tfstate-ilc
```

Storage account:

```text
stdevopslabtfstate<random_suffix>
```

Container:

```text
tfstate
```

The storage account name includes a random suffix because Azure Storage account names must be globally unique.

## Usage

From the repository root:

```powershell
cd infra/terraform/bootstrap
```

Initialize Terraform:

```powershell
terraform init
```

Review the plan:

```powershell
terraform plan -out=tfplan
```

Apply the bootstrap configuration:

```powershell
terraform apply tfplan
```

Show outputs:

```powershell
terraform output
```

You need the following output:

```text
storage_account_name
```

## Configure the Dev Backend

After bootstrap completes, copy the `storage_account_name` output into:

```text
infra/terraform/environments/dev/backend.tf
```

Replace:

```hcl
storage_account_name = "REPLACE_AFTER_BOOTSTRAP"
```

with the real output value, for example:

```hcl
storage_account_name = "stdevopslabtfstate7x3k"
```

Then initialize the dev environment backend:

```powershell
cd ../environments/dev
terraform init -migrate-state
```

If Terraform asks whether to copy/migrate existing local state to the new backend, confirm.

## Backend State Key

The dev environment stores its state at this key:

```text
dev/terraform.tfstate
```

Inside the storage container:

```text
tfstate
```

## Bootstrap State

The bootstrap configuration itself keeps local state by design.

This is acceptable because it manages the storage account that is used by the rest of the project.

Do not delete the bootstrap state unless you intentionally want to stop managing the remote state storage resources through Terraform.

## Cost Notes

The bootstrap resources are expected to stay running.

For this project, the cost should be very small because the storage account only stores Terraform state files and state versions.

The AKS environment is the main cost driver, not the Terraform state storage account.

Expected lifecycle:

```text
Keep:
  rg-devops-lab-tfstate-ilc

Create/destroy as needed:
  rg-devops-lab-dev-ilc
```

## Do Not Commit

Do not commit local Terraform runtime files:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
tfplan
terraform.tfvars
terraform.auto.tfvars.json
*.tfstate
*.tfstate.*
```

## Safe to Commit

Safe files to commit from this directory:

```text
main.tf
variables.tf
outputs.tf
versions.tf
providers.tf
README.md
```

## Cleanup

Only destroy the bootstrap layer if you intentionally want to remove the remote Terraform state backend.

```powershell
cd infra/terraform/bootstrap
terraform destroy
```

Before doing that, make sure no environment still depends on the remote state stored in that account.