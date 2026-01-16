#!/bin/bash

# Script de deployment para VPS de DigitalOcean
# Este script se ejecuta en el servidor después de que GitHub Actions copie los archivos

set -e

echo "🚀 Iniciando deployment de AMEFA Services..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar que docker-compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ docker-compose no está instalado${NC}"
    exit 1
fi

# Verificar que el archivo .env existe
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  Archivo .env no encontrado. Usando valores por defecto.${NC}"
    echo -e "${YELLOW}   Asegúrate de configurar las variables de entorno necesarias.${NC}"
fi

# Detener servicios existentes
echo -e "${YELLOW}📦 Deteniendo servicios existentes...${NC}"
docker-compose down || true

# Limpiar imágenes antiguas (opcional, descomentar si quieres limpiar)
# echo -e "${YELLOW}🧹 Limpiando imágenes antiguas...${NC}"
# docker-compose down --rmi all || true

# Construir y levantar servicios
echo -e "${GREEN}🔨 Construyendo y levantando servicios...${NC}"
docker-compose pull || true  # Intentar actualizar imágenes desde registry
docker-compose build --no-cache
docker-compose up -d

# Esperar a que los servicios estén saludables
echo -e "${YELLOW}⏳ Esperando a que los servicios estén listos...${NC}"
sleep 10

# Verificar estado de los servicios
echo -e "${GREEN}📊 Estado de los servicios:${NC}"
docker-compose ps

# Mostrar logs de los últimos 50 líneas
echo -e "${GREEN}📋 Últimos logs:${NC}"
docker-compose logs --tail=50

echo -e "${GREEN}✅ Deployment completado!${NC}"
echo -e "${GREEN}🌐 Servicios disponibles en:${NC}"
echo -e "   - Gateway: http://localhost:${GATEWAY_PORT:-8080}"
echo -e "   - API: http://localhost:${API_PORT:-8081}"
echo -e "   - Web: http://localhost:${WEB_PORT:-3000}"
