# Deployment Automático - Cómo Funciona

## 🎯 Respuesta Rápida

**NO**, el comando `docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d` **NO se ejecuta solo una vez**.

Se ejecuta **cada vez que hay cambios** en los branches `dev` o `main`, gracias a los **GitHub Actions workflows** que ya están configurados.

## 🔄 Flujo Automático Completo

### 1. Cuando haces push a `dev` o `main`:

```
Tu máquina local
    ↓
git push origin dev
    ↓
GitHub detecta el cambio
    ↓
GitHub Actions se activa automáticamente
    ↓
Workflow ejecuta estos pasos:
    1. Construye la imagen Docker
    2. Sube la imagen a Docker Hub
    3. Se conecta al VPS vía SSH
    4. Ejecuta: docker-compose pull (descarga nueva imagen)
    5. Ejecuta: docker-compose up -d (reinicia el servicio)
```

### 2. El comando `docker-compose up -d` es inteligente:

- **Si el servicio NO existe**: Lo crea y lo inicia
- **Si el servicio YA existe**: Lo actualiza con la nueva imagen y lo reinicia
- **Si no hay cambios**: No hace nada (idempotente)

## 📋 Workflows Configurados

Ya tienes estos workflows que se ejecutan automáticamente:

### 1. `deploy-web.yml` - Para AMEFA.Web

**Se activa cuando:**
- Push a `main` o `develop`
- Cambios en `AMEFA.Web/**`

**Qué hace:**
```bash
# En GitHub Actions (automático):
1. Construye imagen Docker de AMEFA.Web
2. Sube a Docker Hub
3. Se conecta al VPS
4. Ejecuta: docker-compose -f docker-compose.yml -f docker-compose.staging.yml pull web
5. Ejecuta: docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d web
```

### 2. `deploy-api.yml` - Para AMEFAService.API

**Se activa cuando:**
- Push a `main` o `develop`
- Cambios en `AMEFAService.API/**`

### 3. `deploy-gateway.yml` - Para AMEFAService.Gateway

**Se activa cuando:**
- Push a `main` o `develop`
- Cambios en `AMEFAService.Gateway/**`

### 4. `deploy-orchestration.yml` - Para todo el stack

**Se activa cuando:**
- Push a `main`
- Cambios en archivos de orquestación

## 🎯 Cómo Determina el Ambiente

Los workflows **detectan automáticamente** el branch:

```bash
# En el workflow (automático):
BRANCH_NAME="${{ github.ref_name }}"

if [ "$BRANCH_NAME" = "dev" ] || [ "$BRANCH_NAME" = "develop" ]; then
  COMPOSE_FILES="-f docker-compose.yml -f docker-compose.staging.yml"
  echo "🚀 Deploying to Staging"
else
  COMPOSE_FILES="-f docker-compose.yml"
  echo "🚀 Deploying to Production"
fi

# Luego ejecuta:
docker-compose $COMPOSE_FILES pull
docker-compose $COMPOSE_FILES up -d
```

**Resultado:**
- Push a `dev` → Usa STAGING automáticamente
- Push a `main` → Usa PRODUCTION automáticamente

## 📝 Ejemplo Práctico

### Escenario: Cambias código en AMEFA.Web

```bash
# 1. En tu máquina local
cd AMEFA.Web
# Haces cambios en algún archivo
git add .
git commit -m "feat: nuevo feature"
git push origin dev  # ← Esto activa el workflow automáticamente
```

**Lo que pasa automáticamente:**

1. **GitHub Actions detecta el push**
   - Ve que hay cambios en `AMEFA.Web/**`
   - Activa el workflow `deploy-web.yml`

2. **Construye y sube la imagen**
   - Construye nueva imagen Docker
   - La sube a Docker Hub con tag `dev`

3. **Se conecta al VPS y actualiza**
   ```bash
   # Esto se ejecuta automáticamente en el VPS:
   cd /opt/amefa/AMEFA.Orchestration
   docker login ...
   docker-compose -f docker-compose.yml -f docker-compose.staging.yml pull web
   docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d web
   ```

4. **El servicio se actualiza automáticamente**
   - Descarga la nueva imagen
   - Reinicia el contenedor `amefa-web`
   - Tu cambio está live en staging

## ✅ Lo Que Ya Está Configurado

Los workflows ya están listos. Solo necesitas:

1. ✅ **Configurar GitHub Secrets** (una vez)
   - `VPS_HOST`
   - `VPS_USER`
   - `VPS_SSH_KEY`
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD`
   - `VITE_API_BASE_URL_STAGING`
   - `VITE_API_BASE_URL_PRODUCTION`

2. ✅ **Tener el archivo `.env` en el VPS** (una vez)
   - Con todas las variables configuradas

3. ✅ **Hacer push a `dev` o `main`**
   - El deployment se ejecuta automáticamente

## 🔍 Verificar que Funciona

### 1. Ver workflows en GitHub

1. Ve a tu repositorio en GitHub
2. Click en **Actions**
3. Verás todos los workflows ejecutándose
4. Click en uno para ver los logs

### 2. Ver en el VPS

```bash
# Conectarse al VPS
ssh root@tu-vps-ip

# Ver servicios
cd /opt/amefa/AMEFA.Orchestration
docker-compose ps

# Ver logs recientes
docker-compose logs --tail=100

# Ver cuándo se actualizó la imagen
docker images | grep amefa-web
```

## 🎯 Resumen

| Acción | Qué Pasa |
|--------|----------|
| **Push a `dev`** | Workflow detecta → Construye imagen → Sube a Docker Hub → Se conecta al VPS → Ejecuta `docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d` → Servicio actualizado |
| **Push a `main`** | Workflow detecta → Construye imagen → Sube a Docker Hub → Se conecta al VPS → Ejecuta `docker-compose up -d` → Servicio actualizado |
| **Comando manual** | Solo lo ejecutas si quieres forzar un deployment o hacer troubleshooting |

## 🚀 No Necesitas Hacer Nada Manual

Una vez configurados los secrets y el `.env`, **todo es automático**:

1. Haces cambios en tu código
2. Haces `git push`
3. GitHub Actions hace el resto
4. Tu aplicación se actualiza automáticamente

¡El comando `docker-compose up -d` se ejecuta automáticamente cada vez que hay cambios! 🎉
