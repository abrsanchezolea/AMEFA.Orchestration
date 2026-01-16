# Cómo Deployar: Staging vs Production

## 🎯 Concepto Clave: Archivos de Docker Compose

Docker Compose usa un sistema de **"override"** (sobrescritura) donde puedes combinar múltiples archivos:

- **`docker-compose.yml`** = Archivo base (configuración común)
- **`docker-compose.staging.yml`** = Override para STAGING (sobrescribe valores del base)
- **`docker-compose.prod.yml`** = Override para PRODUCTION (opcional, para usar solo imágenes del registry)

## 📋 Cómo Especificar el Ambiente

### Para STAGING

Usa **DOS archivos** combinados:

```bash
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```

**¿Qué hace esto?**
1. Lee `docker-compose.yml` (configuración base)
2. Lee `docker-compose.staging.yml` (sobrescribe valores para staging)
3. Combina ambos archivos
4. El resultado es la configuración de STAGING

### Para PRODUCTION

Usa **SOLO el archivo base**:

```bash
docker-compose up -d
```

O explícitamente:

```bash
docker-compose -f docker-compose.yml up -d
```

**¿Qué hace esto?**
1. Lee solo `docker-compose.yml` (configuración de production)
2. Usa los valores por defecto de production

## 🔍 Ejemplo Visual

### Archivo Base (`docker-compose.yml`)

```yaml
services:
  api:
    environment:
      - ASPNETCORE_ENVIRONMENT=Production  # ← Valor base
      - Jwt__Issuer=${JWT_ISSUER}
```

### Archivo Staging (`docker-compose.staging.yml`)

```yaml
services:
  api:
    environment:
      - ASPNETCORE_ENVIRONMENT=Staging  # ← Sobrescribe el valor base
```

### Resultado cuando usas STAGING:

```bash
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```

**Resultado combinado:**
```yaml
services:
  api:
    environment:
      - ASPNETCORE_ENVIRONMENT=Staging  # ← Valor de staging (sobrescrito)
      - Jwt__Issuer=${JWT_ISSUER}      # ← Valor del base (mantenido)
```

## 📝 Comandos Completos

### Deploy STAGING

```bash
cd /opt/amefa/AMEFA.Orchestration

# 1. Asegúrate de que .env tiene valores de staging
cat .env  # Verificar

# 2. Deploy con staging
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# 3. Verificar
docker-compose -f docker-compose.yml -f docker-compose.staging.yml ps
docker-compose -f docker-compose.yml -f docker-compose.staging.yml logs -f
```

### Deploy PRODUCTION

```bash
cd /opt/amefa/AMEFA.Orchestration

# 1. Asegúrate de que .env tiene valores de production
cat .env  # Verificar

# 2. Deploy production (solo archivo base)
docker-compose up -d

# 3. Verificar
docker-compose ps
docker-compose logs -f
```

## 🔄 Cambiar de Ambiente

### De Staging a Production

```bash
cd /opt/amefa/AMEFA.Orchestration

# 1. Actualizar .env con valores de production
nano .env
# Cambiar:
# JWT_ISSUER=https://api.tu-dominio.com
# VITE_API_BASE_URL=https://api.tu-dominio.com/api
# etc.

# 2. Detener servicios de staging
docker-compose -f docker-compose.yml -f docker-compose.staging.yml down

# 3. Iniciar servicios de production
docker-compose up -d

# 4. Verificar
docker-compose ps
```

### De Production a Staging

```bash
cd /opt/amefa/AMEFA.Orchestration

# 1. Actualizar .env con valores de staging
nano .env
# Cambiar:
# JWT_ISSUER=https://api-staging.tu-dominio.com
# VITE_API_BASE_URL=https://api-staging.tu-dominio.com/api
# etc.

# 2. Detener servicios de production
docker-compose down

# 3. Iniciar servicios de staging
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# 4. Verificar
docker-compose -f docker-compose.yml -f docker-compose.staging.yml ps
```

## 🎯 Resumen

| Ambiente | Comando | Archivos Usados |
|----------|---------|-----------------|
| **STAGING** | `docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d` | Base + Staging override |
| **PRODUCTION** | `docker-compose up -d` | Solo base |

## ⚠️ Importante

1. **El archivo `.env`** siempre se lee automáticamente (no necesitas especificarlo)
2. **El flag `-f`** especifica qué archivos YML usar
3. **El orden importa**: Los archivos se leen en orden, los últimos sobrescriben a los primeros
4. **Siempre usa el mismo conjunto de archivos** para todos los comandos:
   - Si deployaste con: `docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d`
   - Entonces para logs usa: `docker-compose -f docker-compose.yml -f docker-compose.staging.yml logs`
   - Y para detener usa: `docker-compose -f docker-compose.yml -f docker-compose.staging.yml down`

## 🚀 Script Helper (Opcional)

Puedes crear un script para facilitar el cambio:

```bash
# Crear script
nano /opt/amefa/AMEFA.Orchestration/deploy.sh
```

```bash
#!/bin/bash

ENVIRONMENT=$1

if [ "$ENVIRONMENT" = "staging" ]; then
  echo "🚀 Deploying STAGING..."
  docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
  docker-compose -f docker-compose.yml -f docker-compose.staging.yml ps
elif [ "$ENVIRONMENT" = "production" ]; then
  echo "🚀 Deploying PRODUCTION..."
  docker-compose up -d
  docker-compose ps
else
  echo "Usage: ./deploy.sh [staging|production]"
  exit 1
fi
```

```bash
# Hacer ejecutable
chmod +x deploy.sh

# Usar
./deploy.sh staging
./deploy.sh production
```

¡Eso es todo! El flag `-f` es lo que le dice a Docker Compose qué archivos usar. 🎉
