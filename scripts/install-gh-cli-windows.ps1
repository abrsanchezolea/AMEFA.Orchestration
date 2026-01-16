# Script para instalar GitHub CLI en Windows
# Ejecutar como administrador

Write-Host "🔧 Instalando GitHub CLI en Windows..." -ForegroundColor Cyan

# Verificar si Chocolatey está instalado
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "✅ Chocolatey encontrado. Instalando GitHub CLI..." -ForegroundColor Green
    choco install gh -y
} 
# Verificar si winget está disponible
elseif (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "✅ Winget encontrado. Instalando GitHub CLI..." -ForegroundColor Green
    winget install --id GitHub.cli
}
# Si no hay gestor de paquetes, descargar manualmente
else {
    Write-Host "⚠️  No se encontró Chocolatey ni Winget." -ForegroundColor Yellow
    Write-Host "📥 Descargando GitHub CLI manualmente..." -ForegroundColor Cyan
    
    $downloadUrl = "https://github.com/cli/cli/releases/latest/download/gh_windows_amd64.msi"
    $installerPath = "$env:TEMP\gh_installer.msi"
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath
        Write-Host "✅ Descargado. Ejecutando instalador..." -ForegroundColor Green
        Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet" -Wait
        Write-Host "✅ GitHub CLI instalado. Reinicia PowerShell para usar 'gh'" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Error al descargar: $_" -ForegroundColor Red
        Write-Host "📝 Descarga manual desde: https://cli.github.com/" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "📝 Después de instalar, ejecuta:" -ForegroundColor Cyan
Write-Host "   gh auth login" -ForegroundColor White
