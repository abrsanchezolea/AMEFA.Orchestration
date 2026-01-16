# Solución a Errores de Docker Compose

## 🐛 Problemas Encontrados

### Error 1: Variable "vQw7" no definida

**Causa:** En la contraseña `AMEFA_Staging2024!K9#mPx$vQw7@Secure`, Docker Compose interpreta `$vQw7` como una variable.

**Solución:** Escapar el `$` duplicándolo: `$$` se convierte en un `$` literal.

```yaml
# ❌ Antes (causa error)
- SuperAdmin__Password=${SUPERADMIN_PASSWORD:-AMEFA_Staging2024!K9#mPx$vQw7@Secure}

# ✅ Después (corregido)
- SuperAdmin__Password=${SUPERADMIN_PASSWORD:-AMEFA_Staging2024!K9#mPx$$vQw7@Secure}
```

### Error 2: "service 'api' depends on undefined service 'sqlserver'"

**Causa:** El servicio `api` en `docker-compose.yml` depende de `sqlserver`, pero cuando se combina con `docker-compose.staging.yml`, la dependencia no se elimina correctamente.

**Solución:** En `docker-compose.staging.yml`, sobrescribir `depends_on` con una dependencia válida (gateway) en lugar de dejarlo vacío.

```yaml
# ❌ Antes (causa error)
api:
  depends_on: []

# ✅ Después (corregido)
api:
  depends_on:
    - gateway
```

## ✅ Archivos Corregidos

Los archivos ya están corregidos. Ahora puedes ejecutar:

```bash
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```

## 🔍 Verificar

```bash
# Verificar que no hay errores
docker-compose -f docker-compose.yml -f docker-compose.staging.yml config

# Ver servicios
docker-compose -f docker-compose.yml -f docker-compose.staging.yml ps
```

## 📝 Notas

1. **Caracteres especiales en contraseñas**: Siempre escapa `$` con `$$` en Docker Compose
2. **Dependencias**: No puedes usar `depends_on: []` para eliminar dependencias, debes sobrescribir con otra dependencia válida
