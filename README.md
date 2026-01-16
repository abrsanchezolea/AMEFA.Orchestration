# AMEFA Orchestration

Este directorio contiene la configuración de Docker Compose para orquestar todos los servicios de AMEFA en un VPS de DigitalOcean.

## Servicios Incluidos

- **SQL Server**: Base de datos para la aplicación (opcional en staging)
- **AMEFAService.API**: API backend en .NET 9.0
- **AMEFAService.Gateway**: API Gateway con Ocelot
- **AMEFA.Web**: Aplicación web frontend en React

## Ambientes

El proyecto soporta dos ambientes:

- **Staging** (branch `dev`): Usa `appsettings.Staging.json` y base de datos externa
- **Production** (branch `main`): Usa `appsettings.Production.json` y SQL Server local

Ver [STAGING.md](./STAGING.md) para más detalles sobre la configuración de staging.

## Requisitos Previos

- Docker y Docker Compose instalados en el VPS
- Acceso SSH al VPS de DigitalOcean
- Variables de entorno configuradas (ver `.env.example`)

## Configuración Inicial

### 1. Configurar Variables de Entorno

Copia el archivo de ejemplo y configura tus variables:

```bash
cp .env.example .env
```

Edita el archivo `.env` con tus valores reales:

```env
# Database
DB_SA_PASSWORD=TuPasswordSeguro123!
DB_NAME=AMEFADb

# JWT
JWT_KEY=TuClaveSecretaMuyLargaYSegura!

# Stripe
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...

# Email
EMAIL_SMTP_USERNAME=tu-email@gmail.com
EMAIL_SMTP_PASSWORD=tu-app-password

# Web - ⚠️ REQUERIDO
# URL del API Gateway para el frontend (ejemplo: https://api.tu-dominio.com/api)
VITE_API_BASE_URL=
# ... etc
```

**⚠️ IMPORTANTE**: `VITE_API_BASE_URL` es **REQUERIDO** y debe estar configurado. El valor por defecto en docker-compose es solo para desarrollo local.

### 2. Configurar el VPS

En tu VPS de DigitalOcean, asegúrate de tener:

```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalación
docker --version
docker-compose --version
```

### 3. Desplegar los Servicios

```bash
# Clonar o copiar los archivos al VPS
cd /opt/amefa  # o el directorio que prefieras
git clone <tu-repo> .  # o copiar los archivos manualmente

# Ir al directorio de orquestación
cd AMEFA.Orchestration

# Configurar .env
cp .env.example .env
nano .env  # Editar con tus valores

# Levantar los servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Ver estado
docker-compose ps
```

## Deployment Automático con GitHub Actions

Los workflows de GitHub Actions están ubicados en `.github/workflows/` dentro de este directorio y están configurados para:

1. Construir las imágenes Docker cuando hay cambios en cada proyecto
2. Subir las imágenes a un registry (Docker Hub o GitHub Container Registry)
3. Conectarse al VPS vía SSH y ejecutar el deployment

### Configurar Secrets en GitHub

Ve a tu repositorio en GitHub → Settings → Secrets and variables → Actions, y agrega:

- `DOCKER_USERNAME`: Tu usuario de Docker Hub
- `DOCKER_PASSWORD`: Tu contraseña/token de Docker Hub
- `VPS_HOST`: IP o dominio de tu VPS
- `VPS_USER`: Usuario SSH del VPS (normalmente `root` o `ubuntu`)
- `VPS_SSH_KEY`: Tu clave privada SSH para acceder al VPS
- `VPS_DEPLOY_PATH`: Ruta donde están los archivos en el VPS (ej: `/opt/amefa/AMEFA.Orchestration`)

### Estructura de Deployment

```
VPS
└── /opt/amefa/
    ├── AMEFA.Orchestration/
    │   ├── docker-compose.yml
    │   ├── .env
    │   └── deploy.sh
    ├── AMEFAService.API/  (opcional, solo si construyes localmente)
    ├── AMEFAService.Gateway/  (opcional)
    └── AMEFA.Web/  (opcional)
```

## Comandos Útiles

### Production (branch main)

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f api
docker-compose logs -f gateway
docker-compose logs -f web

# Reiniciar un servicio
docker-compose restart api

# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes (⚠️ elimina la base de datos)
docker-compose down -v

# Reconstruir un servicio específico
docker-compose build --no-cache api
docker-compose up -d api

# Ver estado de los servicios
docker-compose ps

# Ejecutar comandos dentro de un contenedor
docker-compose exec api bash
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "TuPassword"
```

### Staging (branch dev)

```bash
# Levantar servicios con configuración staging
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# Ver logs
docker-compose -f docker-compose.yml -f docker-compose.staging.yml logs -f

# Ver estado
docker-compose -f docker-compose.yml -f docker-compose.staging.yml ps

# Reiniciar un servicio
docker-compose -f docker-compose.yml -f docker-compose.staging.yml restart api
```

Ver [STAGING.md](./STAGING.md) para más información sobre staging.

## Puertos

Por defecto, los servicios están expuestos en:

- **Gateway**: `8080` (puerto externo)
- **API**: `8081` (puerto externo, solo para debugging)
- **Web**: `3000` (puerto externo)
- **SQL Server**: `1433` (puerto externo, solo para debugging)

Los servicios se comunican internamente usando la red Docker `amefa-network`.

## Health Checks

Todos los servicios tienen health checks configurados:

- **SQL Server**: Verifica que acepta conexiones
- **API**: Verifica `/swagger`
- **Gateway**: Verifica `/health`
- **Web**: Verifica que el servidor responde

## Troubleshooting

### Los servicios no inician

1. Verifica los logs: `docker-compose logs`
2. Verifica que el archivo `.env` existe y tiene valores válidos
3. Verifica que los puertos no están en uso: `netstat -tulpn | grep :8080`

### La base de datos no conecta

1. Verifica que SQL Server está saludable: `docker-compose ps sqlserver`
2. Verifica la contraseña en `.env`
3. Verifica los logs: `docker-compose logs sqlserver`

### Los servicios no se comunican

1. Verifica que están en la misma red: `docker network inspect amefa-network`
2. Verifica que los nombres de servicio coinciden (api, gateway, sqlserver)

## Seguridad

⚠️ **IMPORTANTE**: 

- Nunca subas el archivo `.env` al repositorio
- Usa contraseñas fuertes para la base de datos
- Configura un firewall en el VPS (solo expón los puertos necesarios)
- Considera usar un reverse proxy (Nginx) para HTTPS
- Usa secrets de GitHub para información sensible

## Reverse Proxy con Nginx (Opcional)

Para exponer los servicios con HTTPS, puedes configurar Nginx:

```nginx
server {
    listen 80;
    server_name tu-dominio.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Luego configura Let's Encrypt para HTTPS.

## Actualización de Servicios

Cuando GitHub Actions despliega una nueva versión:

1. Las imágenes se construyen y suben al registry
2. El workflow se conecta al VPS
3. Ejecuta `docker-compose pull` para actualizar las imágenes
4. Ejecuta `docker-compose up -d` para reiniciar los servicios

Puedes también actualizar manualmente:

```bash
cd /opt/amefa/AMEFA.Orchestration
docker-compose pull
docker-compose up -d
```
