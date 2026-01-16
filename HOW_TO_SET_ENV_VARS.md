# Cómo Configurar Variables de Entorno para Docker Compose

## 📋 Resumen

Docker Compose **lee automáticamente** las variables de entorno desde un archivo `.env` ubicado en el mismo directorio que `docker-compose.yml`. Este archivo **NO se versiona** (está en `.gitignore`) y contiene todos los secretos y configuraciones sensibles.

## 🔄 Cómo Funciona

### 1. Docker Compose Lee Variables Automáticamente

Cuando ejecutas:
```bash
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```

Docker Compose automáticamente:
1. ✅ Busca un archivo `.env` en el mismo directorio
2. ✅ Lee todas las variables definidas en ese archivo
3. ✅ Las inyecta en los contenedores usando la sintaxis `${VARIABLE_NAME}`

### 2. Ejemplo de Configuración

En `docker-compose.staging.yml` tienes:
```yaml
environment:
  - Stripe__SecretKey=${STRIPE_SECRET_KEY}
  - Stripe__PublishableKey=${STRIPE_PUBLISHABLE_KEY}
```

Docker Compose busca `STRIPE_SECRET_KEY` en:
- ✅ Archivo `.env` (prioridad)
- ✅ Variables de entorno del sistema
- ❌ Si no existe, el valor será vacío (puede causar errores)

## 📝 Pasos para Configurar

### Paso 1: Crear el Archivo `.env` en el VPS

En el servidor (VPS), en el directorio `/opt/amefa/AMEFA.Orchestration`:

```bash
# Conectarse al VPS
ssh root@tu-vps-ip

# Ir al directorio de orquestación
cd /opt/amefa/AMEFA.Orchestration

# Copiar el archivo de ejemplo
cp env.staging.example .env

# Editar el archivo con tus valores reales
nano .env
```

### Paso 2: Configurar los Valores Reales

Edita el archivo `.env` y reemplaza los placeholders con valores reales:

```env
# Stripe Configuration
STRIPE_SECRET_KEY=sk_test_51SQut3PFLMaWWqfnxr0AFlb24kPEWoGks5kE5viCXzL0J8MAvZK9MUZth2TsUQXkwCsxx1RsLzdlxYnsIJunatsc00gy3X241t
STRIPE_PUBLISHABLE_KEY=pk_test_51SQut3PFLMaWWqfnMe5x7r1C6PJfA3oUPxdHp1VWWGHFJ3LnBW9dgD0KQtBtXv1qfx0hLRr8D0TXe2PAiEGjgHo7006ciMiPIt
STRIPE_WEBHOOK_SECRET=whsec_sIrvX5oFpnHei75RdB4IrekTPh1bV9yx

# Email Configuration
EMAIL_SMTP_PASSWORD=qsutkluclhwyywzm

# Database Configuration
STAGING_DB_CONNECTION_STRING=Server=db33665.databaseasp.net;Database=db33665;User Id=db33665;Password=hK=9Z6m@2_Xw;Encrypt=False;MultipleActiveResultSets=True;TrustServerCertificate=True;

# JWT Configuration
JWT_ISSUER=http://159.223.9.97:8080
JWT_AUDIENCE=http://159.223.9.97:8080

# API Base URL
VITE_API_BASE_URL=http://159.223.9.97:8080/api
```

### Paso 3: Verificar que el Archivo Está Protegido

El archivo `.env` debe estar en `.gitignore` (ya está configurado):

```bash
# Verificar que .env está en .gitignore
cat .gitignore | grep "\.env"
```

## 🔐 Seguridad

### ✅ Buenas Prácticas

1. **Nunca subas `.env` al repositorio**
   - El archivo `.env` está en `.gitignore`
   - Solo los archivos `.example` se versionan

2. **Usa diferentes archivos para diferentes entornos**
   - `.env` para producción
   - `.env.staging` para staging (opcional, puedes usar el mismo `.env`)

3. **Protege el archivo en el servidor**
   ```bash
   # Dar permisos restrictivos
   chmod 600 .env
   ```

### 🔄 Alternativa: Variables de Entorno del Sistema

También puedes exportar las variables antes de ejecutar docker-compose:

```bash
export STRIPE_SECRET_KEY=sk_test_...
export STRIPE_PUBLISHABLE_KEY=pk_test_...
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```

Pero es más conveniente usar el archivo `.env`.

## 📋 Variables Requeridas

### Para Staging (docker-compose.staging.yml)

Las siguientes variables **DEBEN** estar configuradas en `.env`:

```env
# ⚠️ REQUERIDAS (sin estas, los servicios fallarán)
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=
STRIPE_WEBHOOK_SECRET=
EMAIL_SMTP_PASSWORD=
STAGING_DB_CONNECTION_STRING=
JWT_ISSUER=
JWT_AUDIENCE=
VITE_API_BASE_URL=
EMAIL_BASE_URL=
EMAIL_WEBAPP_URL=
```

### Para Production (docker-compose.yml)

Mismas variables, pero con valores de producción.

## 🚀 Despliegue Automático

Cuando GitHub Actions despliega, los secretos vienen de **GitHub Secrets**, no del archivo `.env` del VPS. El archivo `.env` solo se usa cuando ejecutas docker-compose manualmente en el VPS.

Para despliegue automático:
- Los workflows de GitHub Actions usan `${{ secrets.STRIPE_SECRET_KEY }}`
- Estos secrets se configuran en: Settings → Secrets and variables → Actions

## ✅ Verificación

Para verificar que las variables se están leyendo correctamente:

```bash
# Ver qué variables está leyendo docker-compose
docker-compose config

# Ver las variables de un servicio específico
docker-compose config | grep -A 20 "api:"
```

## 📚 Referencias

- [Docker Compose Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [Docker Compose .env file](https://docs.docker.com/compose/env-file/)
