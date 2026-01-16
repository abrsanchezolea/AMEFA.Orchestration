# Cómo Copiar Archivos al VPS

## 🎯 Problema

El error `cp: cannot stat 'env.example': No such file or directory` significa que el archivo `env.example` **no existe en el VPS**.

Necesitas **copiar los archivos primero** antes de poder crear el `.env`.

## ✅ Solución: Copiar Archivos al VPS

Tienes **3 opciones** para copiar los archivos:

### Opción 1: Clonar el Repositorio (Recomendado) ✅

```bash
# En el VPS
cd /opt/amefa

# Clonar el repositorio completo
git clone https://github.com/tu-usuario/AMEFAService.git .

# O si el directorio ya existe:
cd /opt/amefa
git clone https://github.com/tu-usuario/AMEFAService.git temp
cp -r temp/AMEFA.Orchestration/* AMEFA.Orchestration/
rm -rf temp

# Ir al directorio de orquestación
cd /opt/amefa/AMEFA.Orchestration

# Ahora SÍ puedes copiar env.example
cp env.example .env
nano .env
```

### Opción 2: Copiar Archivos Manualmente desde tu Máquina Local

**Desde tu máquina local:**

```bash
# Asegúrate de estar en el directorio del proyecto
cd C:\Users\abrsa\source\repos\AMEFAService\AMEFA.Orchestration

# Copiar archivos necesarios al VPS
scp env.example root@tu-vps-ip:/opt/amefa/AMEFA.Orchestration/
scp env.staging.example root@tu-vps-ip:/opt/amefa/AMEFA.Orchestration/
scp docker-compose.yml root@tu-vps-ip:/opt/amefa/AMEFA.Orchestration/
scp docker-compose.staging.yml root@tu-vps-ip:/opt/amefa/AMEFA.Orchestration/
```

**Luego en el VPS:**

```bash
# Conectarse al VPS
ssh root@tu-vps-ip

# Ir al directorio
cd /opt/amefa/AMEFA.Orchestration

# Verificar que los archivos están ahí
ls -la
# Debes ver: env.example, docker-compose.yml, etc.

# Ahora SÍ puedes crear .env
cp env.example .env
nano .env
```

### Opción 3: Crear el Archivo .env Manualmente

Si no puedes copiar `env.example`, puedes crear el `.env` directamente:

**En el VPS:**

```bash
cd /opt/amefa/AMEFA.Orchestration

# Crear archivo .env desde cero
nano .env
```

Y pegar este contenido (ajusta los valores):

```env
# Database Configuration
DB_SA_PASSWORD=TuPasswordSeguro123!
DB_NAME=AMEFADb
DB_PORT=1433

# API Configuration
API_PORT=8081

# Gateway Configuration
GATEWAY_PORT=8080

# Web Configuration
WEB_PORT=3000
# ⚠️ REQUERIDO: URL del API Gateway para el frontend
VITE_API_BASE_URL=https://api-staging.tu-dominio.com/api

# JWT Configuration
# ⚠️ REQUERIDO: JWT Key debe ser una clave secreta de al menos 32 caracteres
JWT_KEY=TuClaveSecretaMuyLargaYSeguraDeAlMenos32Caracteres!
# ⚠️ REQUERIDO: JWT Issuer y Audience
JWT_ISSUER=https://api-staging.tu-dominio.com
JWT_AUDIENCE=https://api-staging.tu-dominio.com
JWT_EXPIRES_IN_MINUTES=1440

# Stripe Configuration
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Email Configuration
EMAIL_SMTP_HOST=smtp.gmail.com
EMAIL_SMTP_PORT=587
EMAIL_SMTP_USERNAME=your-email@gmail.com
EMAIL_SMTP_PASSWORD=your-app-password
EMAIL_FROM_EMAIL=your-email@gmail.com
EMAIL_FROM_NAME=AMEFA
EMAIL_SUPPORT_EMAIL=soporteapp@miamefa.com
EMAIL_SUPPORT_PHONE=+52 3312118519
# ⚠️ REQUERIDO: URL base del API para emails
EMAIL_BASE_URL=https://api-staging.tu-dominio.com
# ⚠️ REQUERIDO: URL de la aplicación web
EMAIL_WEBAPP_URL=https://www-staging.tu-dominio.com
EMAIL_WEBAPP_LABEL=https://www.miamefa.com

# Map Service Configuration
MAP_SERVICE_PROVIDER=OpenStreetMap
GOOGLE_MAPS_API_KEY=your-google-maps-api-key

# SuperAdmin Configuration
SUPERADMIN_EMAIL=admin@amefa.com
SUPERADMIN_PASSWORD=AMEFA_Base2024!K9#mPx$vQw7@Secure
SUPERADMIN_FULLNAME=Super Administrator
```

## 📋 Pasos Completos Recomendados

### Paso 1: Copiar Archivos al VPS

**Opción A: Desde tu máquina local (Windows PowerShell):**

```powershell
# En PowerShell de Windows
cd C:\Users\abrsa\source\repos\AMEFAService\AMEFA.Orchestration

# Copiar archivos
scp env.example root@tu-vps-ip:/opt/amefa/AMEFA.Orchestration/
scp env.staging.example root@tu-vps-ip:/opt/amefa/AMEFA.Orchestration/
scp docker-compose.yml root@tu-vps-ip:/opt/amefa/AMEFA.Orchestration/
scp docker-compose.staging.yml root@tu-vps-ip:/opt/amefa/AMEFA.Orchestration/
```

**Opción B: Clonar repo en el VPS:**

```bash
# En el VPS
cd /opt/amefa
git clone https://github.com/tu-usuario/AMEFAService.git .
cd AMEFA.Orchestration
```

### Paso 2: Verificar que los Archivos Están en el VPS

```bash
# En el VPS
cd /opt/amefa/AMEFA.Orchestration
ls -la

# Debes ver:
# - env.example
# - env.staging.example
# - docker-compose.yml
# - docker-compose.staging.yml
```

### Paso 3: Crear el Archivo .env

```bash
# En el VPS
cd /opt/amefa/AMEFA.Orchestration

# Ahora SÍ funciona
cp env.example .env
nano .env
```

## 🔍 Verificar

```bash
# En el VPS
cd /opt/amefa/AMEFA.Orchestration

# Ver archivos
ls -la | grep -E "env|docker-compose"

# Debes ver:
# docker-compose.yml
# docker-compose.staging.yml
# env.example
# env.staging.example
# .env (después de crearlo)
```

## ✅ Resumen

1. **Primero**: Copiar archivos al VPS (git clone o scp)
2. **Segundo**: Verificar que `env.example` existe
3. **Tercero**: Crear `.env` con `cp env.example .env`
4. **Cuarto**: Editar `.env` con tus valores

**El error ocurre porque los archivos no están en el VPS todavía. Primero cópialos, luego crea el `.env`.** 🎯
