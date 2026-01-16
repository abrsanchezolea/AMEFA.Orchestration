# Cómo Eliminar Secretos del Historial de Git

## ⚠️ Problema

GitHub está bloqueando el push porque detectó secretos en commits anteriores del historial de Git. Aunque hayas eliminado los secretos de los archivos actuales, siguen existiendo en el historial.

## 🔍 Secretos Detectados

1. **Docker Personal Access Token** en `scripts/secrets-repository.json.example:3`
2. **Stripe Test API Secret Key** en varios archivos y commits anteriores

## ✅ Solución: Limpiar el Historial

### Opción 1: Usar git-filter-repo (Recomendado)

1. **Instalar git-filter-repo**:
   ```bash
   # Windows (con pip)
   pip install git-filter-repo
   ```

2. **Eliminar el archivo del historial**:
   ```bash
   git filter-repo --path scripts/secrets-repository.json.example --invert-paths
   ```

3. **Eliminar secretos específicos del historial**:
   ```bash
   # Eliminar Docker token (reemplaza con tu token real)
   git filter-repo --replace-text <(echo 'dckr_pat_TU_TOKEN_AQUI==>dckr_pat_PLACEHOLDER')
   
   # Eliminar Stripe keys (reemplaza con tu clave real)
   git filter-repo --replace-text <(echo 'sk_test_TU_CLAVE_AQUI==>sk_test_PLACEHOLDER')
   ```

### Opción 2: Force Push (Solo si es necesario)

**⚠️ ADVERTENCIA**: Esto reescribe el historial. Solo hazlo si:
- Es un repositorio personal o tienes permiso
- Todos los colaboradores están de acuerdo
- Has hecho backup

```bash
# Crear un nuevo commit sin los secretos
git commit --amend -m "fix: remove secrets from example files"

# Force push (CUIDADO: esto reescribe el historial)
git push origin main --force
```

### Opción 3: Crear Nuevo Commit Limpio

Si no puedes reescribir el historial:

1. **Elimina los archivos problemáticos**:
   ```bash
   git rm scripts/secrets-repository.json.example
   git rm ENV_WITH_IP_EXAMPLE.md  # Si existe
   ```

2. **Asegúrate de que todos los archivos tienen placeholders**:
   - ✅ `env.staging.example` - Ya tiene placeholders
   - ✅ `docker-compose.staging.yml` - Ya usa variables
   - ✅ `ENV_VARS_FLOW.md` - Ya corregido
   - ✅ `HOW_TO_SET_ENV_VARS.md` - Ya corregido

3. **Commit y push**:
   ```bash
   git add .
   git commit -m "fix: remove all secrets from example files and documentation"
   git push origin main
   ```

## 🔄 Rotar Secretos Expuestos

**IMPORTANTE**: Si los secretos ya fueron expuestos en el historial:

1. **Docker Personal Access Token**:
   - Ve a: https://hub.docker.com/settings/security
   - Revoca el token expuesto (busca en el historial de tokens)
   - Genera uno nuevo

2. **Stripe Test Keys**:
   - Ve a: https://dashboard.stripe.com/test/apikeys
   - Revoca las claves expuestas
   - Genera nuevas claves de test

## 📋 Checklist

- [ ] Eliminar archivos con secretos del repositorio
- [ ] Reemplazar todos los secretos reales con placeholders
- [ ] Rotar secretos expuestos (Docker, Stripe)
- [ ] Limpiar historial de Git (si es necesario)
- [ ] Verificar que el push funciona
- [ ] Configurar secrets en GitHub Environments

## 🆘 Si el Push Sigue Fallando

Si después de limpiar los archivos el push sigue fallando:

1. **Usa la URL de GitHub para permitir el secret** (solo si es seguro):
   - Ve a la URL proporcionada en el error
   - Revisa si el secret es realmente sensible
   - Si es un ejemplo/documentación, puedes permitirlo

2. **Contacta al administrador del repositorio** si no tienes permisos para reescribir el historial

## 🔒 Prevención Futura

1. **Usa `.gitignore`** para archivos con secretos:
   ```
   secrets-*.json
   !secrets-*.json.example
   ```

2. **Usa placeholders en archivos de ejemplo**:
   - `sk_test_your_stripe_secret_key_here`
   - `dckr_pat_PLACEHOLDER`

3. **Revisa antes de commit**:
   ```bash
   git diff --cached | grep -i "sk_test\|dckr_pat\|password"
   ```
