#!/bin/bash
# Script para generar archivo .env desde GitHub Secrets
# Este script se ejecuta en el VPS durante el despliegue

set -e

DEPLOY_PATH="${VPS_DEPLOY_PATH:-/opt/amefa/AMEFA.Orchestration}"
BRANCH_NAME="${BRANCH_NAME:-main}"

cd "$DEPLOY_PATH"

# Determinar entorno
if [ "$BRANCH_NAME" = "dev" ] || [ "$BRANCH_NAME" = "develop" ]; then
  ENV_TYPE="staging"
  echo "🔧 Configurando entorno STAGING"
else
  ENV_TYPE="production"
  echo "🔧 Configurando entorno PRODUCTION"
fi

# Crear archivo .env
ENV_FILE=".env"
echo "# Archivo .env generado automáticamente desde GitHub Secrets" > "$ENV_FILE"
echo "# Entorno: $ENV_TYPE" >> "$ENV_FILE"
echo "# Generado: $(date)" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"

# Database Configuration
if [ "$ENV_TYPE" = "staging" ]; then
  echo "# Database Configuration (Staging - External DB)" >> "$ENV_FILE"
  echo "STAGING_DB_CONNECTION_STRING=${STAGING_DB_CONNECTION_STRING}" >> "$ENV_FILE"
else
  echo "# Database Configuration (Production)" >> "$ENV_FILE"
  echo "DB_SA_PASSWORD=${DB_SA_PASSWORD:-YourStrong@Password123}" >> "$ENV_FILE"
  echo "DB_NAME=${DB_NAME:-AMEFADb}" >> "$ENV_FILE"
  echo "DB_PORT=${DB_PORT:-1433}" >> "$ENV_FILE"
fi
echo "" >> "$ENV_FILE"

# API Configuration
echo "# API Configuration" >> "$ENV_FILE"
echo "API_PORT=${API_PORT:-8081}" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"

# Gateway Configuration
echo "# Gateway Configuration" >> "$ENV_FILE"
echo "GATEWAY_PORT=${GATEWAY_PORT:-8080}" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"

# Web Configuration
echo "# Web Configuration" >> "$ENV_FILE"
echo "WEB_PORT=${WEB_PORT:-3000}" >> "$ENV_FILE"
if [ "$ENV_TYPE" = "staging" ]; then
  echo "VITE_API_BASE_URL=${VITE_API_BASE_URL_STAGING}" >> "$ENV_FILE"
else
  echo "VITE_API_BASE_URL=${VITE_API_BASE_URL_PRODUCTION}" >> "$ENV_FILE"
fi
echo "" >> "$ENV_FILE"

# JWT Configuration
echo "# JWT Configuration" >> "$ENV_FILE"
echo "JWT_KEY=${JWT_KEY}" >> "$ENV_FILE"
echo "JWT_ISSUER=${JWT_ISSUER}" >> "$ENV_FILE"
echo "JWT_AUDIENCE=${JWT_AUDIENCE}" >> "$ENV_FILE"
if [ "$ENV_TYPE" = "staging" ]; then
  echo "JWT_EXPIRES_IN_MINUTES=${JWT_EXPIRES_IN_MINUTES:-120}" >> "$ENV_FILE"
else
  echo "JWT_EXPIRES_IN_MINUTES=${JWT_EXPIRES_IN_MINUTES:-1440}" >> "$ENV_FILE"
fi
echo "" >> "$ENV_FILE"

# Stripe Configuration
echo "# Stripe Configuration" >> "$ENV_FILE"
echo "STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}" >> "$ENV_FILE"
echo "STRIPE_PUBLISHABLE_KEY=${STRIPE_PUBLISHABLE_KEY}" >> "$ENV_FILE"
echo "STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK_SECRET}" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"

# Email Configuration
echo "# Email Configuration" >> "$ENV_FILE"
echo "EMAIL_BASE_URL=${EMAIL_BASE_URL}" >> "$ENV_FILE"
echo "EMAIL_SMTP_HOST=${EMAIL_SMTP_HOST:-smtp.gmail.com}" >> "$ENV_FILE"
echo "EMAIL_SMTP_PORT=${EMAIL_SMTP_PORT:-587}" >> "$ENV_FILE"
echo "EMAIL_SMTP_USERNAME=${EMAIL_SMTP_USERNAME}" >> "$ENV_FILE"
echo "EMAIL_SMTP_PASSWORD=${EMAIL_SMTP_PASSWORD}" >> "$ENV_FILE"
echo "EMAIL_FROM_EMAIL=${EMAIL_FROM_EMAIL}" >> "$ENV_FILE"
echo "EMAIL_FROM_NAME=${EMAIL_FROM_NAME:-AMEFA}" >> "$ENV_FILE"
echo "EMAIL_SUPPORT_EMAIL=${EMAIL_SUPPORT_EMAIL}" >> "$ENV_FILE"
echo "EMAIL_SUPPORT_PHONE=${EMAIL_SUPPORT_PHONE}" >> "$ENV_FILE"
echo "EMAIL_WEBAPP_URL=${EMAIL_WEBAPP_URL}" >> "$ENV_FILE"
echo "EMAIL_WEBAPP_LABEL=${EMAIL_WEBAPP_LABEL:-https://www.miamefa.com}" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"

# Map Service Configuration
echo "# Map Service Configuration" >> "$ENV_FILE"
echo "MAP_SERVICE_PROVIDER=${MAP_SERVICE_PROVIDER:-OpenStreetMap}" >> "$ENV_FILE"
echo "GOOGLE_MAPS_API_KEY=${GOOGLE_MAPS_API_KEY:-}" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"

# SuperAdmin Configuration
echo "# SuperAdmin Configuration" >> "$ENV_FILE"
echo "SUPERADMIN_EMAIL=${SUPERADMIN_EMAIL:-admin@amefa.com}" >> "$ENV_FILE"
echo "SUPERADMIN_PASSWORD=${SUPERADMIN_PASSWORD}" >> "$ENV_FILE"
echo "SUPERADMIN_FULLNAME=${SUPERADMIN_FULLNAME:-Super Administrator}" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"

# Cache Configuration
echo "# Cache Configuration" >> "$ENV_FILE"
if [ "$ENV_TYPE" = "staging" ]; then
  echo "CACHE_PHARMACIES_ABSOLUTE=${CACHE_PHARMACIES_ABSOLUTE:-15}" >> "$ENV_FILE"
  echo "CACHE_PHARMACIES_SLIDING=${CACHE_PHARMACIES_SLIDING:-5}" >> "$ENV_FILE"
else
  echo "CACHE_PHARMACIES_ABSOLUTE=${CACHE_PHARMACIES_ABSOLUTE:-60}" >> "$ENV_FILE"
  echo "CACHE_PHARMACIES_SLIDING=${CACHE_PHARMACIES_SLIDING:-10}" >> "$ENV_FILE"
fi
echo "CACHE_PHARMACIES_ENABLED=${CACHE_PHARMACIES_ENABLED:-true}" >> "$ENV_FILE"
echo "CACHE_USERS_ABSOLUTE=${CACHE_USERS_ABSOLUTE:-15}" >> "$ENV_FILE"
echo "CACHE_USERS_SLIDING=${CACHE_USERS_SLIDING:-5}" >> "$ENV_FILE"
echo "CACHE_USERS_ENABLED=${CACHE_USERS_ENABLED:-true}" >> "$ENV_FILE"
echo "CACHE_SIZE_LIMIT=${CACHE_SIZE_LIMIT:-1024}" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"

# Docker Registry Configuration
echo "# Docker Registry Configuration" >> "$ENV_FILE"
echo "DOCKER_USERNAME=${DOCKER_USERNAME}" >> "$ENV_FILE"
echo "DOCKER_REGISTRY=${DOCKER_REGISTRY:-docker.io}" >> "$ENV_FILE"
echo "IMAGE_TAG=${IMAGE_TAG:-$BRANCH_NAME}" >> "$ENV_FILE"

# Proteger el archivo
chmod 600 "$ENV_FILE"
echo "✅ Archivo .env creado y protegido en $DEPLOY_PATH/$ENV_FILE"
