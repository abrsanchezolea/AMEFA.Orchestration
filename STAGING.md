# Guía de Configuración Staging

Esta guía explica cómo usar la configuración de Staging para los 3 proyectos cuando trabajas en el branch `dev`.

## Configuración Staging

Cuando trabajas en el branch `dev`, los servicios utilizan la configuración de `appsettings.Staging.json` que incluye:

- **Base de datos externa**: `db33665.databaseasp.net` (en lugar de SQL Server local)
- **JWT Issuer/Audience**: Configurado mediante variables de entorno (`JWT_ISSUER`, `JWT_AUDIENCE`)
- **Stripe Test Keys**: Para pruebas de pagos
- **Cache con tiempos más cortos**: Para facilitar testing
- **SuperAdmin con password de staging**

## Uso del Docker Compose Staging

### Opción 1: Usar archivo de override (Recomendado)

```bash
# En el VPS
cd /opt/amefa/AMEFA.Orchestration

# Cargar variables de staging
export $(cat .env.staging | xargs)

# Levantar servicios con configuración staging
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# Ver logs
docker-compose -f docker-compose.yml -f docker-compose.staging.yml logs -f
```

### Opción 2: Crear un script de alias

Crea un archivo `deploy-staging.sh`:

```bash
#!/bin/bash
cd /opt/amefa/AMEFA.Orchestration
export $(cat .env.staging | xargs)
docker-compose -f docker-compose.yml -f docker-compose.staging.yml "$@"
```

Luego úsalo así:

```bash
chmod +x deploy-staging.sh
./deploy-staging.sh up -d
./deploy-staging.sh logs -f
./deploy-staging.sh ps
```

## Configuración de Variables de Entorno Staging

1. **Copia el archivo de ejemplo**:
   ```bash
   cp env.staging.example .env.staging
   ```

2. **Edita `.env.staging`** con tus valores:
   ```bash
   nano .env.staging
   ```

3. **Variables importantes para staging**:
   - `STAGING_DB_CONNECTION_STRING`: Cadena de conexión a la base de datos externa
   - `JWT_ISSUER` y `JWT_AUDIENCE`: ⚠️ **REQUERIDO** - URLs del API (ej: `https://api.tu-dominio.com`)
   - `VITE_API_BASE_URL`: ⚠️ **REQUERIDO** - URL del gateway para el frontend (ej: `https://api.tu-dominio.com/api`)
   - `EMAIL_BASE_URL`: ⚠️ **REQUERIDO** - URL base del API para emails (ej: `https://api.tu-dominio.com`)

## Base de Datos en Staging

### Opción A: Usar Base de Datos Externa (Recomendado)

En staging, normalmente se usa la base de datos externa `db33665.databaseasp.net`. En este caso:

1. **No necesitas levantar SQL Server local**:
   ```bash
   # El servicio sqlserver tiene profile 'local-db' y no se levanta por defecto
   # Solo se levanta si usas: docker-compose --profile local-db up sqlserver
   ```

2. **Configura la cadena de conexión en `.env.staging`**:
   ```env
   STAGING_DB_CONNECTION_STRING=Server=db33665.databaseasp.net;Database=db33665;User Id=db33665;Password=tu-password;Encrypt=False;MultipleActiveResultSets=True;TrustServerCertificate=True;
   ```

### Opción B: Usar SQL Server Local

Si prefieres usar SQL Server local también en staging:

1. **Modifica `docker-compose.staging.yml`**:
   ```yaml
   sqlserver:
     # Elimina el profile para que se levante siempre
     # profiles:
     #   - local-db
   ```

2. **Usa la variable de conexión local**:
   ```env
   # En .env.staging, comenta STAGING_DB_CONNECTION_STRING
   # y usa las variables normales:
   DB_SA_PASSWORD=YourStrong@Password123
   DB_NAME=AMEFADb_Staging
   ```

## GitHub Actions y Staging

Los workflows están configurados para detectar automáticamente el branch:

- **Branch `dev`**: Usa `docker-compose.staging.yml` (Staging)
- **Branch `main`**: Usa solo `docker-compose.yml` (Production)

Cuando haces push a `dev`, los workflows:
1. Construyen las imágenes con tag `dev`
2. Se conectan al VPS
3. Ejecutan: `docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d`

## Verificación de Staging

Después de levantar los servicios, verifica que están usando la configuración correcta:

```bash
# Ver logs de la API
docker-compose -f docker-compose.yml -f docker-compose.staging.yml logs api | grep "Environment"

# Deberías ver: "Environment: Staging"

# Verificar que el Gateway está usando ocelot.Staging.Docker.json
docker-compose -f docker-compose.yml -f docker-compose.staging.yml logs gateway | grep "Ocelot configuration file"

# Deberías ver: "Ocelot configuration file: ocelot.Staging.Docker.json"
```

## Diferencias Clave entre Staging y Production

| Aspecto | Staging | Production |
|---------|---------|------------|
| **Base de Datos** | Externa (db33665.databaseasp.net) | SQL Server local |
| **JWT Issuer** | Configurado vía `JWT_ISSUER` | Configurado vía `JWT_ISSUER` |
| **Stripe** | Test Keys | Live Keys |
| **Cache TTL** | 15 minutos | 30 minutos |
| **SuperAdmin Password** | `AMEFA_Staging2024!...` | `AMEFA_Base2024!...` |
| **Logging** | Más verboso | Optimizado |
| **NODE_ENV (Web)** | `staging` | `production` |
| **ASPNETCORE_ENVIRONMENT** | `Staging` | `Production` |

## Troubleshooting

### El servicio no usa la configuración de staging

1. Verifica que estás usando el override correcto:
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.staging.yml config
   ```

2. Verifica la variable de entorno:
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.staging.yml exec api env | grep ASPNETCORE_ENVIRONMENT
   # Debería mostrar: ASPNETCORE_ENVIRONMENT=Staging
   ```

### Error de conexión a la base de datos externa

1. Verifica que la cadena de conexión es correcta
2. Verifica que el servidor de base de datos permite conexiones desde tu VPS
3. Prueba la conexión manualmente:
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.staging.yml exec api dotnet ef dbcontext info
   ```

### El Gateway no encuentra ocelot.Staging.Docker.json

1. Verifica que el archivo existe en `AMEFAService.Gateway/ocelot.Staging.Docker.json`
2. Verifica que está copiado en la imagen Docker
3. Revisa los logs del Gateway para ver qué archivo está intentando cargar

## Migración de Staging a Production

Cuando estés listo para producción:

1. **Cambia al branch `main`**:
   ```bash
   git checkout main
   git merge dev
   ```

2. **Los workflows automáticamente usarán producción** cuando hagas push a `main`

3. **En el VPS, cambia a producción**:
   ```bash
   cd /opt/amefa/AMEFA.Orchestration
   git checkout main
   docker-compose pull
   docker-compose up -d  # Sin el override de staging
   ```
