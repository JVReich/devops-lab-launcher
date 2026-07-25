param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("platform", "stack")]
    [string]$Type,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [ValidateSet("deploy", "uninstall", "status")]
    [string]$Action = "deploy",

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

Write-Host "AKS DevOps Lab Launcher - Stack Deployment"
Write-Host "Type:    $Type"
Write-Host "Name:    $Name"
Write-Host "Action:  $Action"
Write-Host "Catalog: $CatalogPath"
Write-Host ""

if (-not (Test-Path $CatalogPath)) {
    throw "Deployment catalog not found: $CatalogPath"
}

if (-not (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue)) {
    throw "ConvertFrom-Yaml was not found. Install it with: Install-Module powershell-yaml -Scope CurrentUser"
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

if ($config.enabled -eq $false) {
    throw "$Type item '$Name' is disabled in the deployment catalog."
}

$ValuesFilePath = Join-Path $RepoRoot $config.valuesFile

if ($Action -eq "deploy" -and -not (Test-Path $ValuesFilePath)) {
    throw "Values file not found: $ValuesFilePath"
}

Write-Host "Resolved deployment:"
Write-Host "  Namespace:    $($config.namespace)"
Write-Host "  Repo name:    $($config.repoName)"
Write-Host "  Repo URL:     $($config.repoUrl)"
Write-Host "  Chart:        $($config.chart)"
Write-Host "  Release name: $($config.releaseName)"

if ($Action -eq "deploy") {
    Write-Host "  Values file:  $ValuesFilePath"
}

if ($config.hostname) {
    Write-Host "  Hostname:     $($config.hostname)"
}

Write-Host ""

if (-not $Execute) {
    Write-Host "Dry run only. Planned action:"

    if ($Action -eq "deploy") {
        Write-Host "  helm repo add $($config.repoName) $($config.repoUrl)"
        Write-Host "  helm repo update"
        Write-Host "  helm upgrade --install $($config.releaseName) $($config.chart) --namespace $($config.namespace) --create-namespace --values `"$ValuesFilePath`""
    }

    if ($Action -eq "uninstall") {
        Write-Host "  helm uninstall $($config.releaseName) --namespace $($config.namespace)"
    }

    if ($Action -eq "status") {
        Write-Host "  helm status $($config.releaseName) --namespace $($config.namespace)"
    }

    Write-Host ""
    Write-Host "To execute later, run:"
    Write-Host "  .\scripts\deploy-stack.ps1 -Type $Type -Name $Name -Action $Action -Execute"
    exit 0
}

if (-not (Test-CommandExists "helm")) {
    throw "Helm is not installed or not in PATH."
}

if ($Action -eq "deploy") {
    Write-Host "Adding Helm repo..."
    helm repo add $config.repoName $config.repoUrl

    Write-Host "Updating Helm repos..."
    helm repo update

    Write-Host "Deploying release..."
    helm upgrade --install $config.releaseName $config.chart `
        --namespace $config.namespace `
        --create-namespace `
        --values $ValuesFilePath
}

if ($Action -eq "uninstall") {
    Write-Host "Uninstalling release..."
    helm uninstall $config.releaseName --namespace $config.namespace
}

if ($Action -eq "status") {
    Write-Host "Checking release status..."
    helm status $config.releaseName --namespace $config.namespace
}

Write-Host ""
Write-Host "Action completed successfully."