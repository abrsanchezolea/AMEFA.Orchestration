# Script PowerShell para configurar GitHub Secrets masivamente
# Requiere: GitHub CLI (gh) instalado y autenticado

$ErrorActionPreference = "Stop"

$REPO = "abrsanchezolea/AMEFA.Orchestration"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Configurando GitHub Secrets masivamente" -ForegroundColor Cyan
Write-Host "Repositorio: $REPO" -ForegroundColor Cyan
Write-Host ""

# Verificar que gh CLI esta instalado
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: GitHub CLI (gh) no esta instalado" -ForegroundColor Red
    Write-Host "Instala desde: https://cli.github.com/" -ForegroundColor Yellow
    Write-Host "   O ejecuta: .\install-gh-cli-windows.ps1" -ForegroundColor Yellow
    exit 1
}

# Verificar autenticacion
try {
    $null = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Not authenticated"
    }
}
catch {
    Write-Host "ERROR: No estas autenticado en GitHub CLI" -ForegroundColor Red
    Write-Host "Ejecuta: gh auth login" -ForegroundColor Yellow
    exit 1
}

# Funcion para configurar secrets de un environment
function Setup-EnvironmentSecrets {
    param(
        [string]$Environment,
        [string]$SecretsFile
    )
    
    Write-Host "Configurando secrets para environment: $Environment" -ForegroundColor Cyan
    
    if (-not (Test-Path $SecretsFile)) {
        Write-Host "ADVERTENCIA: Archivo no encontrado: $SecretsFile" -ForegroundColor Yellow
        return
    }
    
    # Leer JSON
    try {
        $secrets = Get-Content $SecretsFile -Raw | ConvertFrom-Json
        
        foreach ($key in $secrets.PSObject.Properties.Name) {
            $value = $secrets.$key
            Write-Host "  -> Configurando: $key" -ForegroundColor Gray
            $value | gh secret set $key --env $Environment --repo $REPO
            if ($LASTEXITCODE -ne 0) {
                Write-Host "    ADVERTENCIA: Error al configurar $key" -ForegroundColor Yellow
            }
        }
        
        Write-Host "OK: Secrets configurados para $Environment" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host "ERROR: Error al leer archivo JSON: $_" -ForegroundColor Red
    }
}

# Funcion para configurar repository secrets
function Setup-RepositorySecrets {
    param(
        [string]$SecretsFile
    )
    
    Write-Host "Configurando Repository secrets" -ForegroundColor Cyan
    
    if (-not (Test-Path $SecretsFile)) {
        Write-Host "ADVERTENCIA: Archivo no encontrado: $SecretsFile" -ForegroundColor Yellow
        return
    }
    
    # Leer JSON
    try {
        $secrets = Get-Content $SecretsFile -Raw | ConvertFrom-Json
        
        foreach ($key in $secrets.PSObject.Properties.Name) {
            $value = $secrets.$key
            Write-Host "  -> Configurando: $key" -ForegroundColor Gray
            $value | gh secret set $key --repo $REPO
            if ($LASTEXITCODE -ne 0) {
                Write-Host "    ADVERTENCIA: Error al configurar $key" -ForegroundColor Yellow
            }
        }
        
        Write-Host "OK: Repository secrets configurados" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host "ERROR: Error al leer archivo JSON: $_" -ForegroundColor Red
    }
}

# Verificar que los environments existen
Write-Host "Verificando environments..." -ForegroundColor Cyan
try {
    $null = gh api repos/$REPO/environments/staging 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ADVERTENCIA: Environment 'staging' no existe. Creandolo..." -ForegroundColor Yellow
        $null = gh api repos/$REPO/environments/staging -X PUT -f '{}' 2>&1
    }
}
catch {
    Write-Host "ADVERTENCIA: No se pudo verificar/crear environment 'staging'" -ForegroundColor Yellow
}

try {
    $null = gh api repos/$REPO/environments/production 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ADVERTENCIA: Environment 'production' no existe. Creandolo..." -ForegroundColor Yellow
        $null = gh api repos/$REPO/environments/production -X PUT -f '{}' 2>&1
    }
}
catch {
    Write-Host "ADVERTENCIA: No se pudo verificar/crear environment 'production'" -ForegroundColor Yellow
}

# Configurar secrets
$stagingFile = Join-Path $SCRIPT_DIR "secrets-staging.json"
$productionFile = Join-Path $SCRIPT_DIR "secrets-production.json"
$repositoryFile = Join-Path $SCRIPT_DIR "secrets-repository.json"

if (Test-Path $stagingFile) {
    Setup-EnvironmentSecrets "staging" $stagingFile
}

if (Test-Path $productionFile) {
    Setup-EnvironmentSecrets "production" $productionFile
}

if (Test-Path $repositoryFile) {
    Setup-RepositorySecrets $repositoryFile
}

Write-Host "OK: Configuracion completada" -ForegroundColor Green
Write-Host ""
Write-Host "Verifica los secrets en:" -ForegroundColor Cyan
Write-Host "   https://github.com/$REPO/settings/environments" -ForegroundColor White
