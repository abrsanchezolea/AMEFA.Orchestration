# Guía de Deployment

Esta guía explica cómo configurar el deployment automático con GitHub Actions para el VPS de DigitalOcean.

**Nota**: Los workflows de GitHub Actions están ubicados en `AMEFA.Orchestration/.github/workflows/` porque la orquestación es el componente que coordina todos los servicios. Si cada proyecto tiene su propio repositorio, deberías copiar los workflows correspondientes a cada repositorio.

## Configuración Inicial del VPS

### 1. Preparar el VPS

```bash
# Conectarse al VPS
ssh root@tu-vps-ip

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

### 2. Configurar el Repositorio en el VPS

```bash
# Crear directorio para la aplicación
mkdir -p /opt/amefa
cd /opt/amefa

# Clonar el repositorio (o usar otro método de sincronización)
git clone https://github.com/tu-usuario/AMEFAService.git .

# O si prefieres usar rsync desde GitHub Actions, crea el directorio vacío
mkdir -p /opt/amefa/AMEFA.Orchestration
```

### 3. Configurar Variables de Entorno

```bash
cd /opt/amefa/AMEFA.Orchestration

# Crear archivo .env
cp env.example .env
nano .env  # Editar con tus valores reales
```

**Importante**: Configura todas las variables necesarias, especialmente:
- `DB_SA_PASSWORD`: Contraseña segura para SQL Server
- `JWT_KEY`: Clave secreta para JWT (mínimo 32 caracteres)
- `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`, `STRIPE_WEBHOOK_SECRET`
- Credenciales de email SMTP
- `VITE_API_BASE_URL`: URL pública del gateway (ej: `https://api.tu-dominio.com/api`)

### 4. Configurar SSH para GitHub Actions

```bash
# En tu máquina local, generar clave SSH si no tienes una
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_actions_vps

# Copiar la clave pública al VPS
ssh-copy-id -i ~/.ssh/github_actions_vps.pub root@tu-vps-ip

# Verificar que funciona
ssh -i ~/.ssh/github_actions_vps root@tu-vps-ip
```

## Configuración de GitHub Secrets

Ve a tu repositorio en GitHub: **Settings → Secrets and variables → Actions**

Agrega los siguientes secrets:

### Secrets Requeridos

1. **DOCKER_USERNAME**
   - Tu usuario de Docker Hub
   - Ejemplo: `tu-usuario-dockerhub`

2. **DOCKER_PASSWORD**
   - Tu contraseña o token de acceso de Docker Hub
   - Para crear un token: Docker Hub → Account Settings → Security → New Access Token

3. **VPS_HOST**
   - IP o dominio de tu VPS
   - Ejemplo: `123.45.67.89` o `vps.tu-dominio.com`

4. **VPS_USER**
   - Usuario SSH del VPS
   - Normalmente `root` o `ubuntu`

5. **VPS_SSH_KEY**
   - Contenido completo de tu clave privada SSH
   - Ejecuta en tu máquina local:
     ```bash
     cat ~/.ssh/github_actions_vps
     ```
   - Copia TODO el contenido (incluyendo `-----BEGIN OPENSSH PRIVATE KEY-----` y `-----END OPENSSH PRIVATE KEY-----`)

6. **VPS_DEPLOY_PATH** (Opcional)
   - Ruta donde está el directorio de orquestación en el VPS
   - Por defecto: `/opt/amefa/AMEFA.Orchestration`
   - Solo configúralo si usas una ruta diferente

## Flujo de Deployment

### Deployment Automático

Cuando haces push a `main` o `develop` en cualquiera de los proyectos:

1. **GitHub Actions detecta el cambio**
   - `deploy-web.yml` se activa si hay cambios en `AMEFA.Web/**`
   - `deploy-api.yml` se activa si hay cambios en `AMEFAService.API/**`
   - `deploy-gateway.yml` se activa si hay cambios en `AMEFAService.Gateway/**`

2. **Construcción de la imagen**
   - Se construye la imagen Docker del servicio modificado
   - Se sube al registry (Docker Hub)

3. **Deployment en el VPS**
   - GitHub Actions se conecta al VPS vía SSH
   - Hace login en Docker Hub
   - Ejecuta `docker-compose pull` para actualizar la imagen
   - Ejecuta `docker-compose up -d` para reiniciar el servicio

### Deployment Manual

También puedes ejecutar los workflows manualmente:

1. Ve a **Actions** en GitHub
2. Selecciona el workflow que quieres ejecutar
3. Click en **Run workflow**
4. Selecciona la rama y ejecuta

## Verificación del Deployment

### En GitHub Actions

1. Ve a la pestaña **Actions** en tu repositorio
2. Revisa el estado de los workflows
3. Si hay errores, revisa los logs

### En el VPS

```bash
# Conectarse al VPS
ssh root@tu-vps-ip

# Ir al directorio de orquestación
cd /opt/amefa/AMEFA.Orchestration

# Ver estado de los servicios
docker-compose ps

# Ver logs de un servicio
docker-compose logs -f api
docker-compose logs -f gateway
docker-compose logs -f web

# Verificar que los servicios están saludables
docker-compose ps
# Todos deberían mostrar "healthy" o "Up"
```

## Troubleshooting

### Error: "Cannot connect to Docker daemon"

El usuario SSH no tiene permisos para Docker. Solución:

```bash
# En el VPS
sudo usermod -aG docker $USER
# O si usas root, no debería haber problema
```

### Error: "Image not found" o "pull access denied"

1. Verifica que `DOCKER_USERNAME` y `DOCKER_PASSWORD` están correctos
2. Verifica que las imágenes se subieron correctamente a Docker Hub
3. En el VPS, intenta hacer login manualmente:
   ```bash
   docker login -u tu-usuario
   ```

### Error: "Connection refused" al conectarse al VPS

1. Verifica que `VPS_HOST` y `VPS_USER` son correctos
2. Verifica que la clave SSH está correctamente configurada
3. Verifica que el puerto 22 está abierto en el firewall del VPS

### Los servicios no inician correctamente

1. Revisa los logs: `docker-compose logs`
2. Verifica que el archivo `.env` existe y tiene valores válidos
3. Verifica que los puertos no están en uso
4. Verifica que SQL Server está saludable antes de que la API intente conectarse

### Actualizar todas las imágenes manualmente

```bash
# En el VPS
cd /opt/amefa/AMEFA.Orchestration
docker login -u tu-usuario-dockerhub
docker-compose pull
docker-compose up -d
```

## Configuración de Dominio y HTTPS (Opcional)

Para exponer los servicios con un dominio y HTTPS:

1. **Configurar DNS**: Apunta tu dominio al IP del VPS
2. **Instalar Nginx**:
   ```bash
   apt install nginx certbot python3-certbot-nginx -y
   ```
3. **Configurar Nginx** como reverse proxy
4. **Configurar Let's Encrypt**:
   ```bash
   certbot --nginx -d tu-dominio.com
   ```

Ejemplo de configuración de Nginx:

```nginx
server {
    listen 80;
    server_name tu-dominio.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Monitoreo y Mantenimiento

### Ver uso de recursos

```bash
docker stats
```

### Limpiar recursos no utilizados

```bash
# Eliminar imágenes no utilizadas
docker image prune -a

# Eliminar contenedores detenidos
docker container prune

# Limpiar todo (⚠️ cuidado)
docker system prune -a
```

### Backup de la base de datos

```bash
# Crear backup
docker-compose exec sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "TuPassword" \
  -Q "BACKUP DATABASE AMEFADb TO DISK = '/var/opt/mssql/backup/AMEFADb.bak'"

# Copiar backup fuera del contenedor
docker cp amefa-sqlserver:/var/opt/mssql/backup/AMEFADb.bak ./backup/
```

## Próximos Pasos

1. ✅ Configurar los secrets en GitHub
2. ✅ Configurar el VPS con Docker y Docker Compose
3. ✅ Configurar el archivo `.env` en el VPS
4. ✅ Hacer un push de prueba para verificar el deployment
5. ⚙️ Configurar dominio y HTTPS (opcional)
6. ⚙️ Configurar monitoreo y alertas (opcional)
