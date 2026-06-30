param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("platform", "stack")]
    [string]$Type,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$CatalogPath = "",

    [switch]$Execute
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path "$PSScriptRoot\.."

if ([string]::IsNullOrWhiteSpace($CatalogPath)) {
    $CatalogPath = Join-Path $RepoRoot "deployments\stacks.yaml"
}

function Test-CommandExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

Write-Host "AKS DevOps Lab Launcher - Helm Deployment"
Write-Host "Type: $Type"
Write-Host "Name: $Name"
Write-Host "Catalog: $CatalogPath"
Write-Host ""

if (-not (Test-Path $CatalogPath)) {
    throw "Deployment catalog not found: $CatalogPath"
}

if (-not (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue)) {
    throw "ConvertFrom-Yaml was not found. Run this script with PowerShell 7+, or install a YAML parser module."
}

$catalog = Get-Content $CatalogPath -Raw | ConvertFrom-Yaml

if ($Type -eq "platform") {
    $section = $catalog.platform
}
else {
    $section = $catalog.stacks
}

if (-not $section.$Name) {
    $availableItems = $section.PSObject.Properties.Name -join ", "
    throw "$Type item '$Name' was not found in $CatalogPath. Available $Type items: $availableItems"
}

$config = $section.$Name
$ValuesFilePath = Join-Path $RepoRoot $config.valuesFile

if (-not (Test-Path $ValuesFilePath)) {
    throw "Values file not found: $ValuesFilePath"
}

$commands = @(
    "helm repo add $($config.repoName) $($config.repoUrl)",
    "helm repo update",
    "helm upgrade --install $($config.releaseName) $($config.chart) --namespace $($config.namespace) --create-namespace --values `"$ValuesFilePath`""
)

Write-Host "Resolved deployment:"
Write-Host "  Namespace:    $($config.namespace)"
Write-Host "  Repo name:    $($config.repoName)"
Write-Host "  Repo URL:     $($config.repoUrl)"
Write-Host "  Chart:        $($config.chart)"
Write-Host "  Release name: $($config.releaseName)"
Write-Host "  Values file:  $ValuesFilePath"

if ($config.hostname) {
    Write-Host "  Hostname:     $($config.hostname)"
}

Write-Host ""

if (-not $Execute) {
    Write-Host "Dry run only. Commands that would run:"
    foreach ($command in $commands) {
        Write-Host "  $command"
    }

    Write-Host ""
    Write-Host "To execute later, run:"
    Write-Host "  .\scripts\deploy-stack.ps1 -Type $Type -Name $Name -Execute"
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