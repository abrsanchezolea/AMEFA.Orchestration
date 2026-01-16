# Configuración de .env Usando Solo IP del VPS

## 🎯 Configuración Completa con IP: 159.223.9.97

Si solo tienes la IP del VPS, aquí está cómo quedarían todas las variables:

## 📋 Archivo .env Completo

```env
# Database Configuration
# En staging, normalmente se usa una base de datos externa
# Si usas SQL Server local, configura estas variables:
DB_SA_PASSWORD=YourStrong@Password123
DB_NAME=AMEFADb_Staging
DB_PORT=1433

# Si usas base de datos externa (como db33665.databaseasp.net), configura:
STAGING_DB_CONNECTION_STRING=Server=db33665.databaseasp.net;Database=db33665;User Id=db33665;Password=hK=9Z6m@2_Xw;Encrypt=False;MultipleActiveResultSets=True;TrustServerCertificate=True;

# API Configuration
API_PORT=8081

# Gateway Configuration
GATEWAY_PORT=8080

# Web Configuration
WEB_PORT=3000
# ⚠️ REQUERIDO: URL del API Gateway para el frontend
# Usando IP del VPS
VITE_API_BASE_URL=http://159.223.9.97:8080/api

# JWT Configuration (Staging)
# ⚠️ REQUERIDO: JWT Key debe ser una clave secreta de al menos 32 caracteres
JWT_KEY=R9XNPi/qT15Ab236kuRJNqyH4HzkMnaJW+YajdIH686eK9FJZ9xaM5DDugDcVisfJ4RqGolhv6xVMeRfGBg32A==
# ⚠️ REQUERIDO: JWT Issuer y Audience (usando IP del VPS)
JWT_ISSUER=http://159.223.9.97:8080
JWT_AUDIENCE=http://159.223.9.97:8080
JWT_EXPIRES_IN_MINUTES=120

# Stripe Configuration (Staging - Test Keys)
STRIPE_SECRET_KEY=sk_test_51SQut3PFLMaWWqfnxr0AFlb24kPEWoGks5kE5viCXzL0J8MAvZK9MUZth2TsUQXkwCsxx1RsLzdlxYnsIJunatsc00gy3X241t
STRIPE_PUBLISHABLE_KEY=pk_test_51SQut3PFLMaWWqfnMe5x7r1C6PJfA3oUPxdHp1VWWGHFJ3LnBW9dgD0KQtBtXv1qfx0hLRr8D0TXe2PAiEGjgHo7006ciMiPIt
STRIPE_WEBHOOK_SECRET=whsec_sIrvX5oFpnHei75RdB4IrekTPh1bV9yx

# Email Configuration
# ⚠️ REQUERIDO: URL base del API para emails (usando IP del VPS)
EMAIL_BASE_URL=http://159.223.9.97:8080
EMAIL_SMTP_HOST=smtp.gmail.com
EMAIL_SMTP_PORT=587
EMAIL_SMTP_USERNAME=abrsanchez@gmail.com
EMAIL_SMTP_PASSWORD=qsutkluclhwyywzm
EMAIL_FROM_EMAIL=abrsanchez@gmail.com
EMAIL_FROM_NAME=AMEFA
EMAIL_SUPPORT_EMAIL=soporteapp@miamefa.com
EMAIL_SUPPORT_PHONE=+52 3312118519
# URL de la aplicación web (usando IP del VPS)
EMAIL_WEBAPP_URL=http://159.223.9.97:3000
EMAIL_WEBAPP_LABEL=http://159.223.9.97:3000

# Map Service Configuration
MAP_SERVICE_PROVIDER=OpenStreetMap
GOOGLE_MAPS_API_KEY=your-google-maps-api-key

# SuperAdmin Configuration (Staging)
SUPERADMIN_EMAIL=admin@amefa.com
SUPERADMIN_PASSWORD=AMEFA_Staging2024!K9#mPx$vQw7@Secure
SUPERADMIN_FULLNAME=Super Administrator

# Cache Configuration (Staging - valores más cortos para testing)
CACHE_PHARMACIES_ABSOLUTE=15
CACHE_PHARMACIES_SLIDING=5
CACHE_PHARMACIES_ENABLED=true
CACHE_USERS_ABSOLUTE=15
CACHE_USERS_SLIDING=5
CACHE_USERS_ENABLED=true
CACHE_SIZE_LIMIT=1024

# Docker Registry Configuration
DOCKER_USERNAME=abrsanchez
DOCKER_REGISTRY=docker.io
IMAGE_TAG=dev
```

## 🔍 Variables Clave con la IP

### URLs que Usan la IP del VPS:

| Variable | Valor con IP |
|----------|-------------|
| **VITE_API_BASE_URL** | `http://159.223.9.97:8080/api` |
| **JWT_ISSUER** | `http://159.223.9.97:8080` |
| **JWT_AUDIENCE** | `http://159.223.9.97:8080` |
| **EMAIL_BASE_URL** | `http://159.223.9.97:8080` |
| **EMAIL_WEBAPP_URL** | `http://159.223.9.97:3000` |

## 📝 Explicación de los Puertos

- **Puerto 8080**: Gateway (API) - `http://159.223.9.97:8080`
- **Puerto 3000**: Web Frontend - `http://159.223.9.97:3000`
- **Puerto 8081**: API Backend (interno, no expuesto)

## ⚠️ Importante

1. **Usa HTTP, no HTTPS** cuando uses IP directa (a menos que tengas certificado SSL)
2. **El puerto 8080** es donde corre el Gateway
3. **La ruta `/api`** es donde el Gateway expone los endpoints
4. **El puerto 3000** es donde corre el frontend web

## 🔄 Cuando Tengas un Dominio

Cuando configures un dominio, solo cambia estas variables:

```env
# Cambiar de IP a dominio
VITE_API_BASE_URL=https://api.tu-dominio.com/api
JWT_ISSUER=https://api.tu-dominio.com
JWT_AUDIENCE=https://api.tu-dominio.com
EMAIL_BASE_URL=https://api.tu-dominio.com
EMAIL_WEBAPP_URL=https://www.tu-dominio.com
```

## ✅ Verificar Configuración

Después de configurar el `.env`, verifica:

```bash
# En el VPS
cd /opt/amefa/AMEFA.Orchestration

# Verificar que el .env tiene los valores correctos
grep -E "VITE_API_BASE_URL|JWT_ISSUER|EMAIL_BASE_URL" .env

# Debe mostrar:
# VITE_API_BASE_URL=http://159.223.9.97:8080/api
# JWT_ISSUER=http://159.223.9.97:8080
# JWT_AUDIENCE=http://159.223.9.97:8080
# EMAIL_BASE_URL=http://159.223.9.97:8080
```

## 🎯 Resumen

Con la IP `159.223.9.97`, las URLs principales son:

- **API Gateway**: `http://159.223.9.97:8080/api`
- **Web Frontend**: `http://159.223.9.97:3000`
- **JWT Issuer/Audience**: `http://159.223.9.97:8080`

¡Listo para usar! 🚀
