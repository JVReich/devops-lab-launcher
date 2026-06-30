param(
    [Parameter(Mandatory = $true)]
    [string]$Stack,

    [string]$CatalogPath = "deployments/stacks.yaml",

    [switch]$Execute
)

$ErrorActionPreference = "Stop"

function Test-CommandExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

Write-Host "AKS DevOps Lab Launcher - Stack Deployment"
Write-Host "Stack: $Stack"
Write-Host "Catalog: $CatalogPath"
Write-Host ""

if (-not (Test-Path $CatalogPath)) {
    throw "Deployment catalog not found: $CatalogPath"
}

# PowerShell 7 has ConvertFrom-Yaml.
# Windows PowerShell 5.1 does not include it by default.
if (-not (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue)) {
    throw "ConvertFrom-Yaml was not found. Run this script with PowerShell 7+, or install a YAML parser module."
}

$catalog = Get-Content $CatalogPath -Raw | ConvertFrom-Yaml

if (-not $catalog.stacks.$Stack) {
    $availableStacks = $catalog.stacks.PSObject.Properties.Name -join ", "
    throw "Stack '$Stack' was not found in $CatalogPath. Available stacks: $availableStacks"
}

$stackConfig = $catalog.stacks.$Stack

$commands = @(
    "helm repo add $($stackConfig.repoName) $($stackConfig.repoUrl)",
    "helm repo update",
    "helm upgrade --install $($stackConfig.releaseName) $($stackConfig.chart) --namespace $($stackConfig.namespace) --create-namespace --values $($stackConfig.valuesFile)"
)

Write-Host "Resolved stack configuration:"
Write-Host "  Namespace:    $($stackConfig.namespace)"
Write-Host "  Repo name:    $($stackConfig.repoName)"
Write-Host "  Repo URL:     $($stackConfig.repoUrl)"
Write-Host "  Chart:        $($stackConfig.chart)"
Write-Host "  Release name: $($stackConfig.releaseName)"
Write-Host "  Values file:  $($stackConfig.valuesFile)"
Write-Host "  Hostname:     $($stackConfig.hostname)"
Write-Host ""

if (-not $Execute) {
    Write-Host "Dry run only. Commands that would run:"
    foreach ($command in $commands) {
        Write-Host "  $command"
    }

    Write-Host ""
    Write-Host "To execute later, run:"
    Write-Host "  .\scripts\deploy-stack.ps1 -Stack $Stack -Execute"
    exit 0
}

if (-not (Test-CommandExists "helm")) {
    throw "Helm is not installed or not in PATH."
}

Write-Host "Executing Helm deployment..."
foreach ($command in $commands) {
    Write-Host "Running: $command"
    Invoke-Expression $command
}