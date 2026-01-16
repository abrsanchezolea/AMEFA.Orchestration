# Instalar GitHub CLI en Windows

## 🚀 Método 1: Usando Winget (Recomendado - Windows 10/11)

```powershell
winget install --id GitHub.cli
```

## 🍫 Método 2: Usando Chocolatey

Si tienes Chocolatey instalado:

```powershell
choco install gh -y
```

## 📥 Método 3: Descarga Manual

1. Ve a: https://cli.github.com/
2. Descarga el instalador para Windows (`.msi`)
3. Ejecuta el instalador
4. Reinicia PowerShell

## ✅ Verificar Instalación

Después de instalar, reinicia PowerShell y verifica:

```powershell
gh --version
```

Deberías ver algo como:
```
gh version 2.x.x (2024-xx-xx)
https://github.com/cli/cli/releases/tag/v2.x.x
```

## 🔐 Autenticarse

Una vez instalado, autentícate:

```powershell
gh auth login
```

Sigue las instrucciones:
1. Selecciona `GitHub.com`
2. Selecciona `HTTPS` o `SSH`
3. Autentica en el navegador

## 🎯 Script Automático

También puedes usar el script incluido:

```powershell
cd AMEFA.Orchestration/scripts
.\install-gh-cli-windows.ps1
```

## 📝 Próximos Pasos

Después de instalar y autenticarte:

1. **Crea los archivos JSON** con tus valores reales:
   ```powershell
   cd AMEFA.Orchestration/scripts
   Copy-Item secrets-staging.json.example secrets-staging.json
   Copy-Item secrets-production.json.example secrets-production.json
   Copy-Item secrets-repository.json.example secrets-repository.json
   ```

2. **Edita los archivos** con tus valores reales

3. **Ejecuta el script PowerShell**:
   ```powershell
   .\setup-secrets-powershell.ps1
   ```

## 🆘 Troubleshooting

### "gh: command not found" después de instalar

- **Reinicia PowerShell** (cierra y abre nuevamente)
- Verifica que esté en el PATH: `$env:PATH -split ';' | Select-String 'GitHub'`

### Error de permisos

- Ejecuta PowerShell como **Administrador**
- O instala para el usuario actual: `winget install --id GitHub.cli --scope user`

### No puede autenticarse

- Verifica tu conexión a internet
- Intenta: `gh auth login --web`
- O usa token: `gh auth login --with-token < token.txt`

## 📚 Referencias

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Instalación en Windows](https://cli.github.com/manual/installation#windows)
