param(
    [string]$Environment = "dev"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path "$PSScriptRoot\.."
$TerraformDirectory = Join-Path $RepoRoot "infra\terraform\environments\$Environment"

Write-Host "AKS DevOps Lab Launcher - Terraform Validation"
Write-Host "Environment: $Environment"
Write-Host "Terraform directory: $TerraformDirectory"
Write-Host ""

if (-not (Test-Path $TerraformDirectory)) {
    throw "Terraform environment directory not found: $TerraformDirectory"
}

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    throw "Terraform is not installed or not available in PATH."
}

Push-Location $TerraformDirectory

try {
    Write-Host "Running terraform fmt..."
    terraform fmt -recursive

    Write-Host ""
    Write-Host "Running terraform init..."
    terraform init

    Write-Host ""
    Write-Host "Running terraform validate..."
    terraform validate

    Write-Host ""
    Write-Host "Terraform validation completed successfully."
}
finally {
    Pop-Location
}