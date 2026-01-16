# Eliminar Secretos del Repositorio - Solución Rápida

## 🚨 Problema Actual

GitHub está bloqueando el push porque detectó secretos en commits anteriores. Aunque los archivos actuales ya tienen placeholders, los secretos siguen en el historial.

## ✅ Solución Inmediata

### Paso 1: Verificar que los Archivos Actuales Están Limpios

Los siguientes archivos ya fueron corregidos:
- ✅ `ENV_VARS_FLOW.md` - Placeholders
- ✅ `HOW_TO_SET_ENV_VARS.md` - Placeholders  
- ✅ `docker-compose.staging.yml` - Usa variables
- ✅ `env.staging.example` - Placeholders
- ✅ `scripts/secrets-repository.json.example` - Eliminado

### Paso 2: Crear Commit Limpio

```bash
# Asegúrate de que todos los cambios están staged
git add .

# Crear commit
git commit -m "fix: remove all secrets from example files and documentation"

# Intentar push
git push origin main
```

### Paso 3: Si el Push Sigue Fallando

El problema es que los secretos están en commits anteriores. Tienes dos opciones:

#### Opción A: Permitir el Secret (Solo para Ejemplos)

Si los secretos están en archivos de ejemplo/documentación y no son críticos:

1. Ve a la URL del error:
   ```
   https://github.com/abrsanchezolea/AMEFA.Orchestration/security/secret-scanning/unblock-secret/38MFs1bIXxFccubFXqx7MdZlT3s
   ```

2. Revisa si es seguro permitirlo (solo si es un archivo de ejemplo)

3. Haz clic en "Allow secret"

#### Opción B: Limpiar el Historial (Recomendado)

**⚠️ ADVERTENCIA**: Esto reescribe el historial. Solo si tienes permisos:

```bash
# Instalar git-filter-repo
pip install git-filter-repo

# Eliminar secretos del historial (reemplaza con tus secretos reales)
git filter-repo --replace-text <(echo 'dckr_pat_TU_TOKEN_AQUI==>dckr_pat_PLACEHOLDER')
git filter-repo --replace-text <(echo 'sk_test_TU_CLAVE_AQUI==>sk_test_PLACEHOLDER')

# Force push (CUIDADO)
git push origin main --force
```

## 🔄 Rotar Secretos Expuestos

**IMPORTANTE**: Los secretos ya fueron expuestos, debes rotarlos:

1. **Docker Personal Access Token**:
   - Ve a: https://hub.docker.com/settings/security
   - Revoca el token expuesto (busca en el historial de tokens)
   - Genera uno nuevo

2. **Stripe Test Keys**:
   - Ve a: https://dashboard.stripe.com/test/apikeys
   - Revoca las claves expuestas
   - Genera nuevas claves

## 📝 Próximos Pasos

Después de resolver el push:

1. Configura los secrets en GitHub Environments (ver `ENVIRONMENT_SECRETS_SETUP.md`)
2. Usa los nuevos secretos rotados
3. Nunca vuelvas a subir secretos reales al repositorio
