# Flujo de Variables de Entorno - Cómo Funciona

## 🔄 Diagrama del Flujo

```
┌─────────────────────────────────────────────────────────────┐
│  ARCHIVOS EN EL REPOSITORIO (Versionados)                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  📄 env.example          →  Plantilla para PRODUCCIÓN      │
│  📄 env.staging.example   →  Plantilla para STAGING         │
│  📄 docker-compose.yml    →  Usa ${VARIABLE_NAME}           │
│  📄 docker-compose.staging.yml →  Usa ${VARIABLE_NAME}      │
│                                                              │
│  ⚠️ Estos archivos NO contienen secretos reales            │
│     Solo placeholders como: sk_test_your_stripe_secret...   │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ (Copia manual en el VPS)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  ARCHIVOS EN EL VPS (NO Versionados)                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  📄 .env                    →  Contiene valores REALES      │
│                                (está en .gitignore)         │
│                                                              │
│  Ejemplo de .env:                                           │
│  ┌────────────────────────────────────────────────────┐     │
│  │ STRIPE_SECRET_KEY=sk_test_51SQut3PFLMaWWqfn...    │     │
│  │ EMAIL_SMTP_PASSWORD=qsutkluclhwyywzm              │     │
│  │ STAGING_DB_CONNECTION_STRING=Server=db33665...     │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ (Docker Compose lee automáticamente)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  DOCKER COMPOSE                                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  docker-compose.yml contiene:                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │ environment:                                       │     │
│  │   - Stripe__SecretKey=${STRIPE_SECRET_KEY}        │     │
│  │   - Email__SmtpPassword=${EMAIL_SMTP_PASSWORD}     │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  Docker Compose:                                            │
│  1. ✅ Lee .env automáticamente                            │
│  2. ✅ Reemplaza ${STRIPE_SECRET_KEY} con valor real        │
│  3. ✅ Inyecta en el contenedor                            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  CONTENEDORES DOCKER                                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Contenedor 'api':                                          │
│  ┌────────────────────────────────────────────────────┐     │
│  │ Stripe__SecretKey=sk_test_51SQut3PFLMaWWqfn...     │     │
│  │ Email__SmtpPassword=qsutkluclhwyywzm               │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 📝 Proceso Paso a Paso

### 1. En el Repositorio (Desarrollo)

```bash
# Los archivos .example contienen placeholders
env.staging.example:
  STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
```

### 2. En el VPS (Producción/Staging)

```bash
# 1. Copiar el archivo de ejemplo
cp env.staging.example .env

# 2. Editar con valores reales
nano .env
# Cambiar: sk_test_your_stripe_secret_key_here
# Por:     tu-clave-secreta-de-stripe-real

# 3. Verificar que .env está protegido
ls -la .env
# Debe mostrar: -rw------- (solo lectura para el propietario)
```

### 3. Docker Compose Lee Automáticamente

```bash
# Cuando ejecutas esto:
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# Docker Compose automáticamente:
# ✅ Busca .env en el mismo directorio
# ✅ Lee STRIPE_SECRET_KEY=sk_test_51SQut3PFLMaWWqfn...
# ✅ Reemplaza ${STRIPE_SECRET_KEY} en docker-compose.staging.yml
# ✅ Inyecta el valor en el contenedor
```

## 🔍 Verificación

### Ver qué valores está usando Docker Compose:

```bash
# Ver la configuración completa con valores resueltos
docker-compose config

# Ver solo las variables de entorno del servicio 'api'
docker-compose config | grep -A 30 "api:" | grep -A 20 "environment:"
```

### Ver variables dentro del contenedor:

```bash
# Ver variables de entorno del contenedor ejecutándose
docker exec amefa-api env | grep Stripe
docker exec amefa-api env | grep Email
```

## ⚠️ Importante

### ✅ Lo que SÍ se versiona:
- `env.example` (plantilla con placeholders)
- `env.staging.example` (plantilla con placeholders)
- `docker-compose.yml` (usa `${VARIABLE_NAME}`)
- `docker-compose.staging.yml` (usa `${VARIABLE_NAME}`)

### ❌ Lo que NO se versiona:
- `.env` (contiene secretos reales, está en `.gitignore`)
- `.env.staging` (contiene secretos reales, está en `.gitignore`)

## 🚀 Despliegue Automático (GitHub Actions)

Para despliegue automático, los secretos vienen de **GitHub Secrets**, no del archivo `.env`:

```yaml
# .github/workflows/deploy-api.yml
- name: Deploy to VPS
  uses: appleboy/ssh-action@v1.0.3
  with:
    script: |
      # Los secretos se pasan como variables de entorno
      export STRIPE_SECRET_KEY="${{ secrets.STRIPE_SECRET_KEY }}"
      docker-compose up -d
```

O puedes crear/actualizar el `.env` desde GitHub Secrets:

```bash
# En el script de deploy
cat > .env << EOF
STRIPE_SECRET_KEY=${{ secrets.STRIPE_SECRET_KEY }}
EMAIL_SMTP_PASSWORD=${{ secrets.EMAIL_SMTP_PASSWORD }}
EOF
```

## 📚 Resumen

1. **Repositorio**: Solo plantillas (`.example`) con placeholders
2. **VPS**: Archivo `.env` con valores reales (no versionado)
3. **Docker Compose**: Lee `.env` automáticamente y reemplaza `${VARIABLE}`
4. **Contenedores**: Reciben los valores reales como variables de entorno
