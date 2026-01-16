# Configuración de Environment Secrets en GitHub

## 🎯 Problema Resuelto

Con **Repository secrets** no puedes tener el mismo nombre de secret con valores diferentes para staging y production. Por ejemplo:
- ❌ No puedes tener `JWT_ISSUER` con valor `http://159.223.9.97:8080` para staging
- ❌ Y `JWT_ISSUER` con valor `https://api.tu-dominio.com` para production

**Solución**: Usar **Environment secrets** que permiten tener el mismo nombre con valores diferentes según el environment.

## 📋 Pasos para Configurar

### Paso 1: Crear los Environments

1. Ve a: `https://github.com/abrsanchezolea/AMEFA.Orchestration`
2. **Settings** → **Environments**
3. Haz clic en **New environment**
4. Crea dos environments:
   - **Nombre**: `staging`
   - **Nombre**: `production`

### Paso 2: Configurar Secrets en cada Environment

Para cada environment (`staging` y `production`):

1. Haz clic en el environment (ej: `staging`)
2. En la sección **"Environment secrets"**, haz clic en **"Add secret"**
3. Agrega los siguientes secrets con los valores correspondientes:

#### Secrets para Environment `staging`:

| Secret Name | Valor de Ejemplo |
|-------------|------------------|
| `JWT_ISSUER` | `http://159.223.9.97:8080` |
| `JWT_AUDIENCE` | `http://159.223.9.97:8080` |
| `EMAIL_BASE_URL` | `http://159.223.9.97:8080` |
| `EMAIL_WEBAPP_URL` | `http://159.223.9.97:3000` |
| `VITE_API_BASE_URL` | `http://159.223.9.97:8080/api` |
| `STAGING_DB_CONNECTION_STRING` | `Server=db33665.databaseasp.net;Database=db33665;User Id=db33665;Password=tu-password;Encrypt=False;MultipleActiveResultSets=True;TrustServerCertificate=True;` |
| `JWT_KEY` | `R9XNPi/qT15Ab236kuRJNqyH4HzkMnaJW+YajdIH686eK9FJZ9xaM5DDugDcVisfJ4RqGolhv6xVMeRfGBg32A==` |
| `STRIPE_SECRET_KEY` | `sk_test_...` |
| `STRIPE_PUBLISHABLE_KEY` | `pk_test_...` |
| `STRIPE_WEBHOOK_SECRET` | `whsec_...` |
| `EMAIL_SMTP_USERNAME` | `abrsanchez@gmail.com` |
| `EMAIL_SMTP_PASSWORD` | `tu-contraseña-smtp` |
| `EMAIL_FROM_EMAIL` | `abrsanchez@gmail.com` |
| `EMAIL_SUPPORT_EMAIL` | `soporteapp@miamefa.com` |
| `EMAIL_SUPPORT_PHONE` | `+52 3312118519` |
| `SUPERADMIN_PASSWORD` | `AMEFA_Staging2024!K9#mPxvQw7@Secure` |

#### Secrets para Environment `production`:

| Secret Name | Valor de Ejemplo |
|-------------|------------------|
| `JWT_ISSUER` | `https://api.tu-dominio.com` |
| `JWT_AUDIENCE` | `https://api.tu-dominio.com` |
| `EMAIL_BASE_URL` | `https://api.tu-dominio.com` |
| `EMAIL_WEBAPP_URL` | `https://www.tu-dominio.com` |
| `VITE_API_BASE_URL` | `https://api.tu-dominio.com/api` |
| `DB_SA_PASSWORD` | `YourStrong@Password123` |
| `DB_NAME` | `AMEFADb` |
| `DB_PORT` | `1433` |
| `JWT_KEY` | `tu-clave-jwt-produccion` |
| `STRIPE_SECRET_KEY` | `sk_live_...` (clave LIVE) |
| `STRIPE_PUBLISHABLE_KEY` | `pk_live_...` (clave LIVE) |
| `STRIPE_WEBHOOK_SECRET` | `whsec_...` |
| `EMAIL_SMTP_USERNAME` | `tu-email@dominio.com` |
| `EMAIL_SMTP_PASSWORD` | `tu-contraseña-smtp` |
| `EMAIL_FROM_EMAIL` | `noreply@tu-dominio.com` |
| `EMAIL_SUPPORT_EMAIL` | `soporte@tu-dominio.com` |
| `EMAIL_SUPPORT_PHONE` | `+52 3312118519` |
| `SUPERADMIN_PASSWORD` | `AMEFA_Prod2024!K9#mPxvQw7@Secure` |

### Paso 3: Secrets Comunes (Repository Secrets)

Algunos secrets son comunes a ambos environments y se configuran en **Repository secrets**:

| Secret Name | Descripción |
|-------------|-------------|
| `DOCKER_USERNAME` | Usuario de Docker Hub |
| `DOCKER_PASSWORD` | Contraseña de Docker Hub |
| `VPS_HOST` | IP o dominio del VPS |
| `VPS_USER` | Usuario SSH del VPS |
| `VPS_SSH_KEY` | Clave privada SSH |
| `VPS_DEPLOY_PATH` | Ruta de despliegue (opcional) |

## 🔄 Cómo Funciona

1. Los workflows determinan el environment basado en el branch:
   - Branch `dev` o `develop` → Environment `staging`
   - Branch `main` → Environment `production`

2. GitHub Actions automáticamente usa los secrets del environment correspondiente:
   - Si el workflow usa `environment: staging`, usa los secrets de `staging`
   - Si el workflow usa `environment: production`, usa los secrets de `production`

3. Los secrets de Repository están disponibles en todos los environments.

## ✅ Ventajas

- ✅ Mismo nombre de secret, diferentes valores por environment
- ✅ Más organizado y fácil de mantener
- ✅ Separación clara entre staging y production
- ✅ No necesitas prefijos como `_STAGING` o `_PRODUCTION` en los nombres

## 📝 Ejemplo de Configuración

```
Repository: AMEFA.Orchestration
├── Repository Secrets (comunes)
│   ├── DOCKER_USERNAME
│   ├── DOCKER_PASSWORD
│   ├── VPS_HOST
│   └── ...
│
└── Environments
    ├── staging
    │   ├── JWT_ISSUER = http://159.223.9.97:8080
    │   ├── JWT_AUDIENCE = http://159.223.9.97:8080
    │   ├── EMAIL_BASE_URL = http://159.223.9.97:8080
    │   └── ...
    │
    └── production
        ├── JWT_ISSUER = https://api.tu-dominio.com
        ├── JWT_AUDIENCE = https://api.tu-dominio.com
        ├── EMAIL_BASE_URL = https://api.tu-dominio.com
        └── ...
```

## 🔒 Seguridad

- ✅ Los Environment secrets están encriptados
- ✅ Solo se exponen al environment correspondiente
- ✅ Puedes configurar protection rules por environment
- ✅ Los secrets nunca aparecen en los logs
