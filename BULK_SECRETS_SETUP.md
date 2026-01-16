# Configuración Masiva de GitHub Secrets

## 🚀 Método 1: GitHub CLI (Recomendado)

### Requisitos Previos

1. **Instalar GitHub CLI**:
   
   **Windows (PowerShell)**:
   ```powershell
   # Opción 1: Con Winget (Windows 10/11)
   winget install --id GitHub.cli
   
   # Opción 2: Con Chocolatey
   choco install gh -y
   
   # Opción 3: Script automático
   cd AMEFA.Orchestration/scripts
   .\install-gh-cli-windows.ps1
   
   # Opción 4: Descarga manual desde https://cli.github.com/
   ```
   
   **macOS**:
   ```bash
   brew install gh
   ```
   
   **Linux**:
   ```bash
   sudo apt install gh
   # o
   sudo dnf install gh
   ```
   
   **Ver guía completa**: `INSTALL_GH_CLI_WINDOWS.md`

2. **Autenticarse**:
   ```powershell
   # Windows (PowerShell)
   gh auth login
   
   # O en bash
   gh auth login
   ```

### Pasos para Configurar Secrets Masivamente

1. **Crear archivos JSON con los secrets**:

   **Windows (PowerShell)**:
   ```powershell
   cd AMEFA.Orchestration/scripts
   Copy-Item secrets-staging.json.example secrets-staging.json
   Copy-Item secrets-production.json.example secrets-production.json
   Copy-Item secrets-repository.json.example secrets-repository.json
   ```
   
   **Linux/macOS (Bash)**:
   ```bash
   cd AMEFA.Orchestration/scripts
   cp secrets-staging.json.example secrets-staging.json
   cp secrets-production.json.example secrets-production.json
   cp secrets-repository.json.example secrets-repository.json
   ```

2. **Edita cada archivo con tus valores reales**:
   - Abre los archivos `secrets-*.json` (sin `.example`)
   - Reemplaza los valores de ejemplo con tus valores reales
   - **⚠️ IMPORTANTE**: NO subas estos archivos al repositorio

3. **Ejecutar el script**:
   
   **Windows (PowerShell)**:
   ```powershell
   cd AMEFA.Orchestration/scripts
   .\setup-secrets-powershell.ps1
   ```
   
   **Linux/macOS (Bash)**:
   ```bash
   cd AMEFA.Orchestration/scripts
   chmod +x setup-secrets.sh
   ./setup-secrets.sh
   ```

3. **Verificar**:
   ```bash
   # Ver secrets de staging
   gh secret list --env staging --repo abrsanchezolea/AMEFA.Orchestration
   
   # Ver secrets de production
   gh secret list --env production --repo abrsanchezolea/AMEFA.Orchestration
   
   # Ver repository secrets
   gh secret list --repo abrsanchezolea/AMEFA.Orchestration
   ```

## 🔧 Método 2: Script Manual con GitHub CLI

Si prefieres configurar secrets individualmente desde la línea de comandos:

### Para Environment Secrets

```bash
# Staging
echo "http://159.223.9.97:8080" | gh secret set JWT_ISSUER --env staging --repo abrsanchezolea/AMEFA.Orchestration
echo "http://159.223.9.97:8080" | gh secret set JWT_AUDIENCE --env staging --repo abrsanchezolea/AMEFA.Orchestration
echo "http://159.223.9.97:8080" | gh secret set EMAIL_BASE_URL --env staging --repo abrsanchezolea/AMEFA.Orchestration
# ... etc

# Production
echo "https://api.tu-dominio.com" | gh secret set JWT_ISSUER --env production --repo abrsanchezolea/AMEFA.Orchestration
echo "https://api.tu-dominio.com" | gh secret set JWT_AUDIENCE --env production --repo abrsanchezolea/AMEFA.Orchestration
# ... etc
```

### Para Repository Secrets

```bash
echo "abrsanchez" | gh secret set DOCKER_USERNAME --repo abrsanchezolea/AMEFA.Orchestration
echo "tu-contraseña" | gh secret set DOCKER_PASSWORD --repo abrsanchezolea/AMEFA.Orchestration
# ... etc
```

## 📝 Método 3: Script PowerShell (Windows)

Si estás en Windows y prefieres PowerShell:

```powershell
# Crear archivo secrets-staging.json con tus valores
$secrets = Get-Content secrets-staging.json | ConvertFrom-Json

foreach ($key in $secrets.PSObject.Properties.Name) {
    $value = $secrets.$key
    Write-Host "Configurando: $key"
    $value | gh secret set $key --env staging --repo abrsanchezolea/AMEFA.Orchestration
}
```

## 🔄 Método 4: GitHub API (Avanzado)

Si necesitas automatización más compleja, puedes usar la API directamente:

```bash
# Obtener token
TOKEN=$(gh auth token)

# Crear environment (si no existe)
curl -X PUT \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/abrsanchezolea/AMEFA.Orchestration/environments/staging

# Configurar secret (requiere encriptación con libsodium)
# Ver: https://docs.github.com/en/rest/actions/secrets
```

## ⚠️ Importante: Seguridad

1. **NUNCA subas los archivos JSON con secrets reales al repositorio**
   - Los archivos `.example` están bien
   - Agrega `secrets-*.json` (sin `.example`) al `.gitignore`

2. **Elimina los archivos después de usarlos**:
   ```bash
   rm secrets-staging.json secrets-production.json secrets-repository.json
   ```

3. **Usa variables de entorno en lugar de archivos**:
   ```bash
   # En lugar de archivo, puedes usar variables de entorno
   export JWT_ISSUER="http://159.223.9.97:8080"
   echo "$JWT_ISSUER" | gh secret set JWT_ISSUER --env staging --repo abrsanchezolea/AMEFA.Orchestration
   ```

## 📋 Checklist

- [ ] GitHub CLI instalado
- [ ] Autenticado con `gh auth login`
- [ ] Archivos JSON creados desde los ejemplos
- [ ] Valores reales configurados en los JSON
- [ ] Script ejecutado exitosamente
- [ ] Secrets verificados con `gh secret list`
- [ ] Archivos JSON eliminados (por seguridad)

## 🆘 Troubleshooting

### Error: "gh: command not found"
- Instala GitHub CLI desde: https://cli.github.com/

### Error: "authentication required"
- Ejecuta: `gh auth login`

### Error: "environment not found"
- El script crea los environments automáticamente
- O créalos manualmente en GitHub: Settings → Environments

### Los secrets no aparecen
- Verifica que estás en el repositorio correcto
- Verifica que el environment existe
- Usa `gh secret list` para verificar

## 📚 Referencias

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [GitHub Secrets API](https://docs.github.com/en/rest/actions/secrets)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
