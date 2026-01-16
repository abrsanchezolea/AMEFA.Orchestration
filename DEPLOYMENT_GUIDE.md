# Guía de Deployment en DigitalOcean VPS

Esta guía te llevará paso a paso para configurar y deployar AMEFA en tu VPS de DigitalOcean.

## 📋 Checklist Pre-Deployment

Antes de comenzar, asegúrate de tener:

- [ ] VPS de DigitalOcean creado y accesible
- [ ] Acceso SSH al VPS
- [ ] Cuenta de Docker Hub (o GitHub Container Registry)
- [ ] Repositorio de GitHub con los workflows configurados
- [ ] Dominio configurado (opcional, pero recomendado)

## 🚀 Paso 1: Preparar el VPS

### 1.1 Conectarse al VPS

```bash
ssh root@tu-vps-ip
# O si usas un usuario diferente:
ssh tu-usuario@tu-vps-ip
```

### 1.2 Instalar Docker y Docker Compose

```bash
# Actualizar el sistema
apt update && apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Instalar Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Verificar instalación
docker --version
docker-compose --version
```

### 1.3 Crear estructura de directorios

```bash
# Crear directorio para la aplicación
mkdir -p /opt/amefa/AMEFA.Orchestration
cd /opt/amefa/AMEFA.Orchestration
```

### 1.4 Clonar el repositorio (o preparar para sincronización)

**Opción A: Clonar directamente en el VPS**

```bash
cd /opt/amefa
git clone https://github.com/tu-usuario/AMEFAService.git .
cd AMEFA.Orchestration
```

**Opción B: GitHub Actions sincronizará los archivos (recomendado)**

```bash
# Solo crear el directorio, GitHub Actions copiará los archivos necesarios
mkdir -p /opt/amefa/AMEFA.Orchestration
```

## 🔐 Paso 2: Configurar Variables de Entorno

### 2.1 Crear archivo .env

```bash
cd /opt/amefa/AMEFA.Orchestration

# Para producción (branch main)
cp env.example .env
nano .env

# Para staging (branch dev) - crear también
cp env.staging.example .env.staging
nano .env.staging
```

### 2.2 Configurar variables REQUERIDAS

Edita el archivo `.env` y configura estas variables **OBLIGATORIAS**:

```env
# ⚠️ REQUERIDO: Base de datos
DB_SA_PASSWORD=TuPasswordSeguro123!
DB_NAME=AMEFADb

# ⚠️ REQUERIDO: JWT
JWT_KEY=TuClaveSecretaMuyLargaYSeguraDeAlMenos32Caracteres!
JWT_ISSUER=https://api.tu-dominio.com
JWT_AUDIENCE=https://api.tu-dominio.com

# ⚠️ REQUERIDO: Web Frontend
VITE_API_BASE_URL=https://api.tu-dominio.com/api

# ⚠️ REQUERIDO: Email
EMAIL_BASE_URL=https://api.tu-dominio.com
EMAIL_WEBAPP_URL=https://www.tu-dominio.com
EMAIL_SMTP_USERNAME=tu-email@gmail.com
EMAIL_SMTP_PASSWORD=tu-app-password

# ⚠️ REQUERIDO: Stripe (producción)
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Opcionales pero recomendados
EMAIL_FROM_EMAIL=tu-email@gmail.com
EMAIL_FROM_NAME=AMEFA
EMAIL_SUPPORT_EMAIL=soporte@tu-dominio.com
EMAIL_SUPPORT_PHONE=+52 1234567890
```

**⚠️ IMPORTANTE**: 
- Reemplaza `tu-dominio.com` con tu dominio real
- Para staging, usa URLs de staging (ej: `api-staging.tu-dominio.com`)
- Las variables sin valores por defecto **DEBEN** estar configuradas

### 2.3 Configurar .env.staging (si usas branch dev)

```bash
nano .env.staging
```

Configura las mismas variables pero con valores de staging.

## 🔑 Paso 3: Configurar GitHub Secrets

Ve a tu repositorio en GitHub: **Settings → Secrets and variables → Actions**

### 3.1 Secrets de Docker Hub

1. **DOCKER_USERNAME**
   - Tu usuario de Docker Hub
   - Ejemplo: `tu-usuario-dockerhub`

2. **DOCKER_PASSWORD**
   - Tu contraseña o token de acceso de Docker Hub
   - Para crear un token: Docker Hub → Account Settings → Security → New Access Token

### 3.2 Secrets de VPS

3. **VPS_HOST**
   - IP o dominio de tu VPS
   - Ejemplo: `123.45.67.89` o `vps.tu-dominio.com`

4. **VPS_USER**
   - Usuario SSH del VPS
   - Normalmente `root` o `ubuntu`

5. **VPS_SSH_KEY**
   - Contenido completo de tu clave privada SSH
   - Genera una clave si no tienes:
     ```bash
     # En tu máquina local
     ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_actions_vps
     ```
   - Copia la clave pública al VPS:
     ```bash
     ssh-copy-id -i ~/.ssh/github_actions_vps.pub root@tu-vps-ip
     ```
   - Copia el contenido de la clave privada:
     ```bash
     cat ~/.ssh/github_actions_vps
     ```
   - Copia **TODO** el contenido (incluyendo `-----BEGIN OPENSSH PRIVATE KEY-----` y `-----END OPENSSH PRIVATE KEY-----`)

6. **VPS_DEPLOY_PATH** (Opcional)
   - Ruta donde está el directorio de orquestación en el VPS
   - Por defecto: `/opt/amefa/AMEFA.Orchestration`
   - Solo configúralo si usas una ruta diferente

### 3.3 Secrets de URLs del API

7. **VITE_API_BASE_URL_STAGING**
   - URL del API para ambiente staging
   - Ejemplo: `https://api-staging.tu-dominio.com/api`

8. **VITE_API_BASE_URL_PRODUCTION**
   - URL del API para ambiente production
   - Ejemplo: `https://api.tu-dominio.com/api`

## 📦 Paso 4: Primera Deploy Manual

### 4.1 Copiar archivos necesarios al VPS

Necesitas tener estos archivos en el VPS:

```bash
cd /opt/amefa/AMEFA.Orchestration

# Archivos necesarios:
# - docker-compose.yml
# - docker-compose.staging.yml (si usas staging)
# - .env (o .env.staging)
```

Puedes copiarlos manualmente o usar git:

```bash
# Si clonaste el repo
cd /opt/amefa
git pull

# O copiar manualmente desde tu máquina local
scp docker-compose.yml root@tu-vps-ip:/opt/amefa/AMEFA.Orchestration/
scp docker-compose.staging.yml root@tu-vps-ip:/opt/amefa/AMEFA.Orchestration/
```

### 4.2 Login a Docker Hub en el VPS

```bash
cd /opt/amefa/AMEFA.Orchestration
docker login -u tu-usuario-dockerhub
# Ingresa tu contraseña o token
```

### 4.3 Deploy inicial

**Para Producción (branch main):**

```bash
cd /opt/amefa/AMEFA.Orchestration
docker-compose up -d
```

**Para Staging (branch dev):**

```bash
cd /opt/amefa/AMEFA.Orchestration
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```

### 4.4 Verificar que los servicios están corriendo

```bash
# Ver estado de todos los servicios
docker-compose ps

# Ver logs
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f api
docker-compose logs -f gateway
docker-compose logs -f web
```

## 🔄 Paso 5: Configurar Deployment Automático

Una vez que la primera deploy manual funciona, el deployment automático se activará cuando:

1. Haces push a `main` o `dev` en cualquier proyecto
2. Los workflows detectan cambios y construyen las imágenes
3. Las imágenes se suben a Docker Hub
4. GitHub Actions se conecta al VPS y actualiza los servicios

### 5.1 Probar el deployment automático

```bash
# En tu máquina local
git checkout dev  # o main
# Haz un cambio pequeño (ej: actualizar un comentario)
git add .
git commit -m "test: deployment automático"
git push origin dev
```

Ve a **Actions** en GitHub y verifica que el workflow se ejecuta correctamente.

## 🔍 Paso 6: Verificación y Troubleshooting

### 6.1 Verificar servicios en el VPS

```bash
ssh root@tu-vps-ip
cd /opt/amefa/AMEFA.Orchestration

# Ver estado
docker-compose ps

# Verificar que todos están "Up" y "healthy"
# Deberías ver:
# - amefa-sqlserver: Up
# - amefa-api: Up (healthy)
# - amefa-gateway: Up (healthy)
# - amefa-web: Up
```

### 6.2 Verificar logs

```bash
# Todos los servicios
docker-compose logs --tail=100

# Servicio específico
docker-compose logs -f api
docker-compose logs -f gateway
docker-compose logs -f web
```

### 6.3 Verificar conectividad

```bash
# Desde el VPS, verificar que los puertos están abiertos
netstat -tulpn | grep -E '3000|8080|8081|1433'

# O usar curl para probar endpoints
curl http://localhost:8080/api/health
curl http://localhost:3000
```

### 6.4 Problemas comunes

**Error: "Cannot connect to Docker daemon"**
```bash
# Agregar usuario al grupo docker
sudo usermod -aG docker $USER
# Cerrar sesión y volver a entrar
```

**Error: "Image not found" o "pull access denied"**
```bash
# Verificar login
docker login -u tu-usuario-dockerhub

# Verificar que las imágenes existen en Docker Hub
docker pull tu-usuario-dockerhub/amefa-web:latest
```

**Error: "Connection refused" en GitHub Actions**
- Verifica que `VPS_HOST` y `VPS_USER` son correctos
- Verifica que la clave SSH está correctamente configurada
- Verifica que el puerto 22 está abierto en el firewall

**Los servicios no inician**
```bash
# Revisar logs detallados
docker-compose logs

# Verificar que .env existe y tiene valores válidos
cat .env

# Verificar que los puertos no están en uso
netstat -tulpn | grep -E '3000|8080|8081|1433'
```

## 🌐 Paso 7: Configurar Dominio y HTTPS (Opcional pero Recomendado)

### 7.1 Configurar DNS

En tu proveedor de DNS, apunta tu dominio al IP del VPS:
- `A` record: `@` → `IP-del-VPS`
- `A` record: `api` → `IP-del-VPS` (para el API)
- `A` record: `www` → `IP-del-VPS` (opcional)

### 7.2 Instalar Nginx y Certbot

```bash
# Instalar Nginx
apt install nginx certbot python3-certbot-nginx -y

# Iniciar Nginx
systemctl start nginx
systemctl enable nginx
```

### 7.3 Configurar Nginx como Reverse Proxy

Crea el archivo de configuración:

```bash
nano /etc/nginx/sites-available/amefa
```

Contenido:

```nginx
# Frontend Web
server {
    listen 80;
    server_name tu-dominio.com www.tu-dominio.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# API Gateway
server {
    listen 80;
    server_name api.tu-dominio.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Activar configuración:

```bash
ln -s /etc/nginx/sites-available/amefa /etc/nginx/sites-enabled/
nginx -t  # Verificar configuración
systemctl reload nginx
```

### 7.4 Configurar HTTPS con Let's Encrypt

```bash
# Obtener certificado SSL
certbot --nginx -d tu-dominio.com -d www.tu-dominio.com
certbot --nginx -d api.tu-dominio.com

# Verificar renovación automática
certbot renew --dry-run
```

## 📊 Paso 8: Monitoreo y Mantenimiento

### 8.1 Ver uso de recursos

```bash
docker stats
```

### 8.2 Limpiar recursos no utilizados

```bash
# Eliminar imágenes no utilizadas
docker image prune -a

# Eliminar contenedores detenidos
docker container prune

# Ver espacio usado
docker system df
```

### 8.3 Actualizar servicios manualmente

```bash
cd /opt/amefa/AMEFA.Orchestration

# Actualizar todas las imágenes
docker-compose pull

# Reiniciar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f
```

### 8.4 Backup de base de datos

```bash
# Crear backup
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "${DB_SA_PASSWORD}" \
  -Q "BACKUP DATABASE ${DB_NAME} TO DISK = '/var/opt/mssql/backup/${DB_NAME}.bak'"

# Copiar backup fuera del contenedor
mkdir -p /opt/amefa/backups
docker cp amefa-sqlserver:/var/opt/mssql/backup/${DB_NAME}.bak /opt/amefa/backups/
```

## ✅ Checklist Final

- [ ] VPS configurado con Docker y Docker Compose
- [ ] Archivo `.env` configurado con todas las variables requeridas
- [ ] GitHub Secrets configurados
- [ ] Primera deploy manual exitosa
- [ ] Servicios corriendo y saludables
- [ ] Deployment automático funcionando
- [ ] Dominio y HTTPS configurados (opcional)
- [ ] Monitoreo configurado (opcional)

## 🆘 Soporte

Si tienes problemas:

1. Revisa los logs: `docker-compose logs`
2. Verifica la configuración: `cat .env`
3. Revisa los workflows en GitHub Actions
4. Consulta la documentación en `DEPLOYMENT.md`

¡Listo! Tu aplicación debería estar corriendo en el VPS. 🎉
