# Quick Start Guide

Guía rápida para poner en marcha la orquestación de AMEFA en un VPS de DigitalOcean.

## Pasos Rápidos

### 1. Preparar el VPS (5 minutos)

```bash
# Conectarse al VPS
ssh root@tu-vps-ip

# Instalar Docker y Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Verificar
docker --version && docker-compose --version
```

### 2. Clonar y Configurar (2 minutos)

```bash
# En el VPS
mkdir -p /opt/amefa
cd /opt/amefa
git clone https://github.com/tu-usuario/AMEFAService.git .
cd AMEFA.Orchestration

# Crear .env
cp env.example .env
nano .env  # Editar con tus valores
```

### 3. Configurar GitHub Secrets (3 minutos)

En GitHub: **Settings → Secrets and variables → Actions**

Agrega estos secrets:
- `DOCKER_USERNAME`: Tu usuario de Docker Hub
- `DOCKER_PASSWORD`: Tu token de Docker Hub
- `VPS_HOST`: IP de tu VPS
- `VPS_USER`: `root` o `ubuntu`
- `VPS_SSH_KEY`: Tu clave privada SSH
- `VPS_DEPLOY_PATH`: `/opt/amefa/AMEFA.Orchestration` (opcional)

### 4. Primera Ejecución (10 minutos)

```bash
# En el VPS
cd /opt/amefa/AMEFA.Orchestration

# Levantar servicios (primera vez construye las imágenes)
docker-compose up -d

# Ver logs
docker-compose logs -f

# Ver estado
docker-compose ps
```

### 5. Verificar que Funciona

```bash
# Verificar que los servicios están corriendo
docker-compose ps
# Todos deberían estar "Up" y "healthy"

# Probar endpoints
curl http://localhost:8080/health  # Gateway
curl http://localhost:8081/swagger # API
curl http://localhost:3000        # Web
```

## Variables de Entorno Mínimas Requeridas

En el archivo `.env`, configura al menos:

```env
# Database
DB_SA_PASSWORD=TuPasswordSeguro123!

# JWT (mínimo 32 caracteres)
JWT_KEY=TuClaveSecretaMuyLargaYSeguraDeAlMenos32Caracteres!

# API Base URL para el frontend
VITE_API_BASE_URL=http://tu-vps-ip:8080/api
# O si tienes dominio:
# VITE_API_BASE_URL=https://api.tu-dominio.com/api

# Stripe (si usas pagos)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Email (si usas emails)
EMAIL_SMTP_USERNAME=tu-email@gmail.com
EMAIL_SMTP_PASSWORD=tu-app-password
EMAIL_FROM_EMAIL=tu-email@gmail.com
```

## Comandos Útiles

```bash
# Ver logs
docker-compose logs -f [servicio]

# Reiniciar un servicio
docker-compose restart [servicio]

# Detener todo
docker-compose down

# Actualizar imágenes
docker-compose pull
docker-compose up -d
```

## Troubleshooting Rápido

**Los servicios no inician:**
```bash
docker-compose logs
```

**La base de datos no conecta:**
```bash
docker-compose logs sqlserver
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "TuPassword" -Q "SELECT 1"
```

**Puerto en uso:**
```bash
netstat -tulpn | grep :8080
# Cambiar puerto en .env
```

## Siguiente Paso

Una vez que todo funciona, configura el deployment automático siguiendo `DEPLOYMENT.md`.
