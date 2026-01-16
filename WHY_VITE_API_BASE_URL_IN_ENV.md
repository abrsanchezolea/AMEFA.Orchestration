# ¿Por Qué VITE_API_BASE_URL Necesita Estar en .env?

## 🎯 Respuesta Rápida

**`VITE_API_BASE_URL` se necesita durante el BUILD de la imagen Docker, no en runtime.**

Vite inyecta las variables `VITE_*` en el código JavaScript durante el build. Una vez compilado, el código ya tiene la URL hardcodeada y no puede cambiarse en runtime.

## 🔍 Cómo Funciona

### 1. Durante el BUILD (cuando se construye la imagen)

```dockerfile
# En el Dockerfile de AMEFA.Web
ARG VITE_API_BASE_URL          # ← Se recibe como build argument
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
RUN npm run build              # ← Vite inyecta la variable aquí
```

**Lo que pasa:**
1. Docker Compose lee `VITE_API_BASE_URL` del archivo `.env`
2. Lo pasa como `build arg` al Dockerfile
3. Vite lo inyecta en el código JavaScript durante `npm run build`
4. El código compilado ya tiene la URL hardcodeada

### 2. En el docker-compose.yml

```yaml
web:
  build:
    args:
      - VITE_API_BASE_URL=${VITE_API_BASE_URL}  # ← Lee del .env
```

**Flujo:**
```
.env (VITE_API_BASE_URL=https://api.tu-dominio.com/api)
    ↓
docker-compose.yml (${VITE_API_BASE_URL})
    ↓
Dockerfile (ARG VITE_API_BASE_URL)
    ↓
npm run build (Vite inyecta en el código)
    ↓
Código compilado (ya tiene la URL hardcodeada)
```

## ⚠️ Por Qué NO Puede Ser Solo Variable de Entorno en Runtime

### Si intentas ponerlo solo como environment variable:

```yaml
# ❌ ESTO NO FUNCIONA
web:
  environment:
    - VITE_API_BASE_URL=https://api.tu-dominio.com/api
```

**Problema:**
- Vite ya compiló el código sin la variable
- El código JavaScript compilado no puede leer variables de entorno en runtime
- La aplicación no sabrá a qué URL conectarse

### Por eso necesita ser BUILD ARG:

```yaml
# ✅ ESTO SÍ FUNCIONA
web:
  build:
    args:
      - VITE_API_BASE_URL=${VITE_API_BASE_URL}  # ← Se usa durante el build
```

**Ventaja:**
- Vite inyecta la variable durante el build
- El código compilado ya tiene la URL correcta
- La aplicación funciona correctamente

## 📋 Ejemplo Práctico

### Código Fuente (antes del build):

```javascript
// En authService.js
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;
```

### Código Compilado (después del build):

```javascript
// Vite reemplaza import.meta.env.VITE_API_BASE_URL con el valor real
const API_BASE_URL = "https://api.tu-dominio.com/api";  // ← Hardcodeado
```

**Por eso:**
- Si cambias `VITE_API_BASE_URL` en `.env`, necesitas **reconstruir la imagen**
- No puedes cambiarlo solo reiniciando el contenedor

## 🔄 Flujo Completo

```
1. Tienes .env con: VITE_API_BASE_URL=https://api.tu-dominio.com/api
   ↓
2. docker-compose lee el .env
   ↓
3. docker-compose pasa ${VITE_API_BASE_URL} como build arg
   ↓
4. Dockerfile recibe el build arg
   ↓
5. npm run build ejecuta Vite
   ↓
6. Vite inyecta la URL en el código JavaScript
   ↓
7. Código compilado tiene la URL hardcodeada
   ↓
8. Imagen Docker lista con la URL correcta
```

## 🎯 Resumen

| Aspecto | Explicación |
|---------|-------------|
| **¿Por qué en .env?** | Para que docker-compose lo lea y lo pase como build arg |
| **¿Por qué build arg?** | Porque Vite necesita la variable durante el build, no en runtime |
| **¿Por qué no solo environment?** | Porque el código ya está compilado y no puede leer variables de entorno |
| **¿Cuándo se usa?** | Durante `docker-compose build` o `docker-compose up --build` |

## ✅ Conclusión

Aunque todo esté orquestado en el mismo docker-compose, **`VITE_API_BASE_URL` debe estar en `.env`** porque:

1. Docker Compose lo lee del `.env`
2. Lo pasa como build argument al Dockerfile
3. Vite lo inyecta durante el build
4. El código compilado ya tiene la URL correcta

**Sin el `.env`, docker-compose no sabría qué valor pasar al build, y la imagen se construiría sin la URL correcta.** 🎯
