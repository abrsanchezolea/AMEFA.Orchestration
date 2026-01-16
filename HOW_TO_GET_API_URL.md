# ¿De Dónde Obtener la URL del API (VITE_API_BASE_URL)?

## 🎯 Respuesta Rápida

La URL depende de cómo hayas configurado tu infraestructura. Tienes varias opciones:

## 📋 Opciones para la URL del API

### Opción 1: Usar la IP del VPS Directamente (Más Simple)

Si **NO tienes dominio configurado**:

```env
# En el .env del VPS
VITE_API_BASE_URL=http://TU-IP-VPS:8080/api
```

**Ejemplo:**
```env
VITE_API_BASE_URL=http://123.45.67.89:8080/api
```

**Cómo obtener la IP:**
```bash
# En el VPS
curl ifconfig.me
# O
hostname -I
```

### Opción 2: Usar un Dominio (Recomendado)

Si **tienes un dominio configurado**:

```env
# En el .env del VPS
VITE_API_BASE_URL=https://api.tu-dominio.com/api
```

**Ejemplo:**
```env
VITE_API_BASE_URL=https://api.amefa.com/api
```

### Opción 3: Usar el Dominio de DigitalOcean (Si lo configuraste)

Si configuraste un dominio en DigitalOcean:

```env
# En el .env del VPS
VITE_API_BASE_URL=https://api-staging.tu-dominio.com/api
```

## 🔍 Cómo Determinar la URL Correcta

### Paso 1: Identificar el Puerto del Gateway

El Gateway corre en el puerto **8080** (configurado en docker-compose.yml):

```yaml
gateway:
  ports:
    - "${GATEWAY_PORT:-8080}:8080"
```

### Paso 2: Verificar Cómo Accedes al VPS

**Si accedes por IP:**
```env
VITE_API_BASE_URL=http://TU-IP-VPS:8080/api
```

**Si accedes por dominio:**
```env
VITE_API_BASE_URL=https://api.tu-dominio.com/api
```

### Paso 3: Verificar si Tienes HTTPS

**Si tienes certificado SSL (Let's Encrypt):**
```env
VITE_API_BASE_URL=https://api.tu-dominio.com/api
```

**Si NO tienes SSL:**
```env
VITE_API_BASE_URL=http://TU-IP-VPS:8080/api
```

## 📝 Ejemplos por Escenario

### Escenario 1: Solo IP, Sin Dominio (Desarrollo/Testing)

```env
# Obtener IP del VPS
# En el VPS: curl ifconfig.me
# Resultado: 123.45.67.89

# En .env
VITE_API_BASE_URL=http://123.45.67.89:8080/api
JWT_ISSUER=http://123.45.67.89:8080
JWT_AUDIENCE=http://123.45.67.89:8080
EMAIL_BASE_URL=http://123.45.67.89:8080
```

### Escenario 2: Con Dominio, Sin HTTPS

```env
# Si tienes dominio pero sin SSL
VITE_API_BASE_URL=http://api.tu-dominio.com/api
JWT_ISSUER=http://api.tu-dominio.com
JWT_AUDIENCE=http://api.tu-dominio.com
EMAIL_BASE_URL=http://api.tu-dominio.com
```

### Escenario 3: Con Dominio y HTTPS (Producción)

```env
# Si tienes dominio con SSL
VITE_API_BASE_URL=https://api.tu-dominio.com/api
JWT_ISSUER=https://api.tu-dominio.com
JWT_AUDIENCE=https://api.tu-dominio.com
EMAIL_BASE_URL=https://api.tu-dominio.com
```

### Escenario 4: Staging vs Production

**Staging (branch dev):**
```env
VITE_API_BASE_URL=https://api-staging.tu-dominio.com/api
JWT_ISSUER=https://api-staging.tu-dominio.com
JWT_AUDIENCE=https://api-staging.tu-dominio.com
EMAIL_BASE_URL=https://api-staging.tu-dominio.com
```

**Production (branch main):**
```env
VITE_API_BASE_URL=https://api.tu-dominio.com/api
JWT_ISSUER=https://api.tu-dominio.com
JWT_AUDIENCE=https://api.tu-dominio.com
EMAIL_BASE_URL=https://api.tu-dominio.com
```

## 🔧 Cómo Verificar la URL Correcta

### Paso 1: Verificar que el Gateway Está Corriendo

```bash
# En el VPS
cd /opt/amefa/AMEFA.Orchestration
docker-compose ps

# Debes ver "amefa-gateway" corriendo en el puerto 8080
```

### Paso 2: Probar la URL

**Desde el VPS:**
```bash
# Probar localmente
curl http://localhost:8080/api/health
```

**Desde tu máquina local:**
```bash
# Probar con la IP del VPS
curl http://TU-IP-VPS:8080/api/health

# O con el dominio
curl https://api.tu-dominio.com/api/health
```

### Paso 3: Verificar que el Puerto Está Abierto

```bash
# En el VPS
netstat -tulpn | grep 8080

# Debe mostrar que el puerto 8080 está escuchando
```

## 🎯 Para tu Caso Específico

Basándome en tu configuración actual, veo que estás usando `amefa.runasp.net`. 

**Si ese es tu dominio actual:**

```env
# En .env (staging)
VITE_API_BASE_URL=https://amefa.runasp.net/api
JWT_ISSUER=https://amefa.runasp.net
JWT_AUDIENCE=https://amefa.runasp.net
EMAIL_BASE_URL=https://amefa.runasp.net
```

**Si quieres usar la IP del VPS directamente:**

```bash
# 1. Obtener la IP del VPS
# En el VPS:
curl ifconfig.me

# 2. Usar esa IP en .env
VITE_API_BASE_URL=http://TU-IP:8080/api
```

## ⚠️ Importante

1. **El puerto 8080** es donde corre el Gateway
2. **La ruta `/api`** es donde el Gateway expone los endpoints
3. **Si usas HTTPS**, asegúrate de tener el certificado SSL configurado
4. **Si usas IP directa**, el navegador puede bloquear conexiones HTTP desde HTTPS (mixed content)

## 📋 Checklist

- [ ] Identificar si usas IP o dominio
- [ ] Verificar que el puerto 8080 está abierto
- [ ] Probar la URL con `curl`
- [ ] Configurar la URL en el `.env`
- [ ] Reconstruir la imagen si cambias la URL

## 🆘 Si No Estás Seguro

**Opción más simple para empezar:**

```bash
# 1. Obtener IP del VPS
curl ifconfig.me

# 2. Usar esa IP en .env
VITE_API_BASE_URL=http://TU-IP:8080/api
```

Luego, cuando configures un dominio, puedes cambiarlo.

¡La URL depende de tu infraestructura! 🎯
