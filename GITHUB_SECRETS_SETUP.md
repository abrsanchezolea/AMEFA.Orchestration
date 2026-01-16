# Configuración de GitHub Secrets

## 📋 Resumen

Los workflows de GitHub Actions ahora **generan automáticamente** el archivo `.env` en el VPS desde los GitHub Secrets. Esto significa que no necesitas configurar manualmente el archivo `.env` en el servidor.

## 🔐 Secrets Requeridos

⚠️ **IMPORTANTE**: Usamos **Environment secrets** (NO Repository secrets) porque necesitamos el mismo nombre de secret con valores diferentes para staging y production.

**Repositorio**: `https://github.com/abrsanchezolea/AMEFA.Orchestration`

### 📋 Configuración en 2 Pasos:

1. **Crear Environments**: Settings → Environments → New environment
   - Crea `staging` y `production`

2. **Configurar Secrets**: En cada environment, Settings → Environments → [environment] → Add secret

**Ver guía completa en**: `ENVIRONMENT_SECRETS_SETUP.md`

### Secrets Comunes (Todos los Entornos)

| Secret | Descripción | Ejemplo |
|--------|-------------|---------|
| `DOCKER_USERNAME` | Usuario de Docker Hub | `abrsanchez` |
| `DOCKER_PASSWORD` | Contraseña de Docker Hub | `tu-contraseña` |
| `VPS_HOST` | IP o dominio del VPS | `159.223.9.97` |
| `VPS_USER` | Usuario SSH del VPS | `root` |
| `VPS_SSH_KEY` | Clave privada SSH | `-----BEGIN RSA PRIVATE KEY-----...` |
| `VPS_DEPLOY_PATH` | Ruta de despliegue (opcional) | `/opt/amefa/AMEFA.Orchestration` |

### Secrets de Base de Datos

#### Para Staging
| Secret | Descripción |
|--------|-------------|
| `STAGING_DB_CONNECTION_STRING` | Connection string completo de la BD externa |

#### Para Production
| Secret | Descripción |
|--------|-------------|
| `DB_SA_PASSWORD` | Contraseña del SA de SQL Server |
| `DB_NAME` | Nombre de la base de datos |
| `DB_PORT` | Puerto de SQL Server (opcional, default: 1433) |

### Secrets de JWT

| Secret | Descripción |
|--------|-------------|
| `JWT_KEY` | Clave secreta para JWT (mínimo 32 caracteres) |
| `JWT_ISSUER` | Issuer del JWT (ej: `http://159.223.9.97:8080`) |
| `JWT_AUDIENCE` | Audience del JWT (ej: `http://159.223.9.97:8080`) |
| `JWT_EXPIRES_IN_MINUTES` | Tiempo de expiración (opcional, default: 120 staging, 1440 production) |

### Secrets de Stripe

| Secret | Descripción |
|--------|-------------|
| `STRIPE_SECRET_KEY` | Clave secreta de Stripe (test o live) |
| `STRIPE_PUBLISHABLE_KEY` | Clave pública de Stripe |
| `STRIPE_WEBHOOK_SECRET` | Secreto del webhook de Stripe |

### Secrets de Email

| Secret | Descripción |
|--------|-------------|
| `EMAIL_BASE_URL` | URL base del API (ej: `http://159.223.9.97:8080`) |
| `EMAIL_SMTP_HOST` | Servidor SMTP (opcional, default: `smtp.gmail.com`) |
| `EMAIL_SMTP_PORT` | Puerto SMTP (opcional, default: `587`) |
| `EMAIL_SMTP_USERNAME` | Usuario SMTP |
| `EMAIL_SMTP_PASSWORD` | Contraseña SMTP (o contraseña de aplicación) |
| `EMAIL_FROM_EMAIL` | Email remitente |
| `EMAIL_FROM_NAME` | Nombre remitente (opcional, default: `AMEFA`) |
| `EMAIL_SUPPORT_EMAIL` | Email de soporte |
| `EMAIL_SUPPORT_PHONE` | Teléfono de soporte |
| `EMAIL_WEBAPP_URL` | URL de la aplicación web |
| `EMAIL_WEBAPP_LABEL` | Etiqueta de la URL (opcional, default: `https://www.miamefa.com`) |

### Secrets de Frontend

| Secret | Descripción |
|--------|-------------|
| `VITE_API_BASE_URL_STAGING` | URL del API Gateway para staging (ej: `http://159.223.9.97:8080/api`) |
| `VITE_API_BASE_URL_PRODUCTION` | URL del API Gateway para production |

### Secrets de SuperAdmin

| Secret | Descripción |
|--------|-------------|
| `SUPERADMIN_EMAIL` | Email del super administrador (opcional, default: `admin@amefa.com`) |
| `SUPERADMIN_PASSWORD` | Contraseña del super administrador |
| `SUPERADMIN_FULLNAME` | Nombre completo (opcional, default: `Super Administrator`) |

### Secrets Opcionales

| Secret | Descripción |
|--------|-------------|
| `GOOGLE_MAPS_API_KEY` | Clave de API de Google Maps (opcional) |

## 🔄 Cómo Funciona

1. **Push a GitHub**: Cuando haces push a `main` o `develop`
2. **Workflow se Dispara**: GitHub Actions ejecuta el workflow correspondiente
3. **Genera .env**: El workflow genera automáticamente el archivo `.env` en el VPS desde los secrets
4. **Docker Compose**: Lee el `.env` y despliega los servicios

## 📝 Ejemplo de Configuración

### Para Staging (branch `dev` o `develop`)

```bash
# En GitHub Secrets, configura:
STAGING_DB_CONNECTION_STRING=Server=db33665.databaseasp.net;Database=db33665;User Id=db33665;Password=tu-password;Encrypt=False;MultipleActiveResultSets=True;TrustServerCertificate=True;
VITE_API_BASE_URL_STAGING=http://159.223.9.97:8080/api
JWT_ISSUER=http://159.223.9.97:8080
JWT_AUDIENCE=http://159.223.9.97:8080
EMAIL_BASE_URL=http://159.223.9.97:8080
EMAIL_WEBAPP_URL=http://159.223.9.97:3000
```

### Para Production (branch `main`)

```bash
# En GitHub Secrets, configura:
DB_SA_PASSWORD=YourStrong@Password123
DB_NAME=AMEFADb
VITE_API_BASE_URL_PRODUCTION=https://api.tu-dominio.com/api
JWT_ISSUER=https://api.tu-dominio.com
JWT_AUDIENCE=https://api.tu-dominio.com
EMAIL_BASE_URL=https://api.tu-dominio.com
EMAIL_WEBAPP_URL=https://www.tu-dominio.com
```

## ✅ Verificación

Después de configurar los secrets, puedes verificar que funcionan:

1. Haz un push a `dev` o `main`
2. El workflow generará automáticamente el `.env` en el VPS
3. Los servicios se desplegarán con la configuración correcta

## 🔒 Seguridad

- ✅ Los secrets están encriptados en GitHub
- ✅ El archivo `.env` se genera con permisos `600` (solo lectura para el propietario)
- ✅ El archivo `.env` está en `.gitignore` y no se versiona
- ✅ Los secrets nunca aparecen en los logs de GitHub Actions

## 🆘 Troubleshooting

### El archivo .env no se genera

- Verifica que todos los secrets requeridos estén configurados
- Revisa los logs del workflow en GitHub Actions
- Verifica que el VPS tenga permisos de escritura en el directorio

### Los servicios fallan al iniciar

- Verifica que el archivo `.env` se haya generado correctamente: `cat .env` en el VPS
- Verifica que todas las variables requeridas estén presentes
- Revisa los logs de Docker: `docker-compose logs`
