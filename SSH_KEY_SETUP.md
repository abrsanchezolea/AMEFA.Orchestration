# Configuración de Clave SSH para GitHub Actions

## 🔐 Generar Nueva Clave SSH

### Paso 1: Generar la clave (en tu máquina local)

```bash
# Generar clave SSH sin passphrase (recomendado para CI/CD)
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_actions_deploy -N ""

# O si ed25519 no está disponible, usa RSA
ssh-keygen -t rsa -b 4096 -C "github-actions-deploy" -f ~/.ssh/github_actions_deploy -N ""
```

### Paso 2: Copiar la clave pública al VPS

```bash
# Opción 1: Usando ssh-copy-id (si tienes acceso con otra clave)
ssh-copy-id -i ~/.ssh/github_actions_deploy.pub root@tu-vps-ip

# Opción 2: Manualmente
# 1. Ver la clave pública
cat ~/.ssh/github_actions_deploy.pub

# 2. Conectarte al VPS
ssh root@tu-vps-ip

# 3. En el VPS, agregar la clave
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "PEGA_AQUI_LA_CLAVE_PUBLICA" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### Paso 3: Probar la conexión

```bash
# Probar conexión con la nueva clave
ssh -i ~/.ssh/github_actions_deploy root@tu-vps-ip
```

### Paso 4: Configurar en GitHub Secrets

1. **Ver la clave privada**:
   ```bash
   cat ~/.ssh/github_actions_deploy
   ```

2. **Copiar TODO el contenido** (incluyendo `-----BEGIN OPENSSH PRIVATE KEY-----` y `-----END OPENSSH PRIVATE KEY-----`)

3. **En GitHub**:
   - Ve a: `https://github.com/abrsanchezolea/AMEFA.Orchestration/settings/secrets/actions`
   - Edita o crea el secret `VPS_SSH_KEY`
   - Pega la clave privada completa
   - Guarda

4. **Si la clave tiene passphrase**:
   - Crea/edita el secret `VPS_SSH_PASSPHRASE`
   - Pega la passphrase
   - Si no tiene passphrase, deja este secret vacío o no lo crees

## ✅ Verificación

Después de configurar, el workflow debería poder conectarse al VPS.

## 🔒 Seguridad

- ✅ La clave privada está encriptada en GitHub Secrets
- ✅ Solo se usa para CI/CD, no para acceso manual
- ✅ Puedes revocar el acceso eliminando la clave pública del VPS

## 🆘 Troubleshooting

### Error: "unable to authenticate"

1. **Verifica que la clave pública está en el VPS**:
   ```bash
   ssh root@tu-vps-ip "cat ~/.ssh/authorized_keys"
   ```

2. **Verifica el formato de la clave privada en GitHub**:
   - Debe empezar con `-----BEGIN OPENSSH PRIVATE KEY-----`
   - Debe terminar con `-----END OPENSSH PRIVATE KEY-----`
   - No debe tener espacios extra al inicio/final

3. **Verifica el usuario SSH**:
   - El secret `VPS_USER` debe ser el usuario correcto (generalmente `root`)

4. **Verifica permisos en el VPS**:
   ```bash
   ssh root@tu-vps-ip "ls -la ~/.ssh"
   # Debe mostrar:
   # drwx------ .ssh
   # -rw------- authorized_keys
   ```
