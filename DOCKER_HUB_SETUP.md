# Cómo Obtener DOCKER_USERNAME y DOCKER_PASSWORD

## 🎯 DOCKER_USERNAME

**Es simplemente tu nombre de usuario de Docker Hub.**

### Opción 1: Si ya tienes cuenta en Docker Hub

1. Ve a [https://hub.docker.com](https://hub.docker.com)
2. Inicia sesión
3. Tu **DOCKER_USERNAME** es el nombre de usuario que usas para iniciar sesión

### Opción 2: Si NO tienes cuenta

1. Ve a [https://hub.docker.com/signup](https://hub.docker.com/signup)
2. Crea una cuenta gratuita
3. Elige un nombre de usuario (este será tu **DOCKER_USERNAME**)

**Ejemplo:**
- Si tu nombre de usuario es `juanperez`
- Entonces: `DOCKER_USERNAME = juanperez`

## 🔐 DOCKER_PASSWORD

**Es tu contraseña o un Access Token de Docker Hub.**

### Opción 1: Usar tu contraseña (No recomendado)

Puedes usar tu contraseña de Docker Hub directamente, pero **NO es recomendado** por seguridad.

### Opción 2: Crear un Access Token (Recomendado) ✅

Los Access Tokens son más seguros porque:
- Puedes revocarlos fácilmente
- Tienen permisos específicos
- No comprometen tu contraseña principal

#### Pasos para crear un Access Token:

1. **Inicia sesión en Docker Hub**
   - Ve a [https://hub.docker.com](https://hub.docker.com)
   - Inicia sesión con tu cuenta

2. **Ve a Account Settings**
   - Click en tu nombre de usuario (arriba a la derecha)
   - Click en **Account Settings**

3. **Ve a Security**
   - En el menú lateral, click en **Security**

4. **Crear Access Token**
   - Click en **New Access Token**
   - **Description**: Pon algo descriptivo como "GitHub Actions AMEFA"
   - **Permissions**: Selecciona **Read & Write** (necesitas escribir para subir imágenes)
   - Click en **Generate**

5. **Copiar el Token**
   - ⚠️ **IMPORTANTE**: El token solo se muestra UNA VEZ
   - Copia el token inmediatamente
   - Este token es tu **DOCKER_PASSWORD**

**Ejemplo:**
```
Token generado: dckr_pat_1234567890abcdefghijklmnopqrstuvwxyz
Entonces: DOCKER_PASSWORD = dckr_pat_1234567890abcdefghijklmnopqrstuvwxyz
```

## 📝 Resumen de Valores

| Secret | Valor | Dónde Obtenerlo |
|--------|-------|-----------------|
| **DOCKER_USERNAME** | Tu nombre de usuario de Docker Hub | [hub.docker.com](https://hub.docker.com) - Tu nombre de usuario |
| **DOCKER_PASSWORD** | Tu Access Token de Docker Hub | Docker Hub → Account Settings → Security → New Access Token |

## 🔧 Configurar en GitHub

Una vez que tengas los valores:

1. Ve a tu repositorio en GitHub
2. Click en **Settings** (arriba del repositorio)
3. En el menú lateral, click en **Secrets and variables** → **Actions**
4. Click en **New repository secret**

### Agregar DOCKER_USERNAME:

1. **Name**: `DOCKER_USERNAME`
2. **Secret**: Tu nombre de usuario de Docker Hub (ej: `juanperez`)
3. Click en **Add secret**

### Agregar DOCKER_PASSWORD:

1. **Name**: `DOCKER_PASSWORD`
2. **Secret**: Tu Access Token de Docker Hub (ej: `dckr_pat_1234567890...`)
3. Click en **Add secret**

## ✅ Verificar que Funciona

Puedes verificar que las credenciales funcionan:

### Desde tu máquina local:

```bash
# Login a Docker Hub
docker login -u tu-usuario-dockerhub
# Ingresa tu contraseña o token cuando te lo pida

# Si funciona, verás: "Login Succeeded"
```

### Desde el VPS:

```bash
# Conectarse al VPS
ssh root@tu-vps-ip

# Login a Docker Hub
docker login -u tu-usuario-dockerhub
# Ingresa tu contraseña o token

# Si funciona, verás: "Login Succeeded"
```

## 🎯 Ejemplo Completo

**Escenario:**
- Nombre de usuario Docker Hub: `amefa-dev`
- Access Token: `dckr_pat_AbCdEf1234567890XyZ`

**En GitHub Secrets:**
- `DOCKER_USERNAME` = `amefa-dev`
- `DOCKER_PASSWORD` = `dckr_pat_AbCdEf1234567890XyZ`

**En el workflow, se usarán así:**
```yaml
- name: Log in to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKER_USERNAME }}  # = amefa-dev
    password: ${{ secrets.DOCKER_PASSWORD }}    # = dckr_pat_AbCdEf1234567890XyZ
```

## ⚠️ Importante

1. **Nunca compartas tu Access Token** públicamente
2. **Si pierdes el token**, simplemente revócalo y crea uno nuevo
3. **Los tokens tienen permisos específicos** - asegúrate de darle "Read & Write"
4. **El token solo se muestra una vez** - guárdalo en un lugar seguro

## 🆘 Troubleshooting

### Error: "authentication required"

- Verifica que `DOCKER_USERNAME` es correcto
- Verifica que `DOCKER_PASSWORD` es el token completo (no tu contraseña)
- Verifica que el token tiene permisos "Read & Write"

### Error: "unauthorized: authentication required"

- El token puede haber expirado o sido revocado
- Crea un nuevo token y actualiza el secret en GitHub

### Error: "pull access denied"

- Verifica que el token tiene permisos "Read"
- Verifica que estás usando el nombre de usuario correcto

¡Listo! Con estos valores configurados, GitHub Actions podrá subir las imágenes a Docker Hub automáticamente. 🎉
