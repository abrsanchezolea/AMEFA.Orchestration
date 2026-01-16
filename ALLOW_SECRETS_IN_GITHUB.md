# Permitir Secrets en GitHub - Solución Rápida

## 🎯 Problema

GitHub está bloqueando el push porque detectó secretos en commits anteriores. Aunque los archivos actuales ya tienen placeholders, los secretos siguen en el historial.

## ✅ Solución: Permitir el Secret en GitHub

Como estos secretos están en archivos de **ejemplo/documentación** y ya fueron expuestos, puedes permitirlos en GitHub.

### Paso 1: Permitir Docker Personal Access Token

1. **Abre esta URL**:
   ```
   https://github.com/abrsanchezolea/AMEFA.Orchestration/security/secret-scanning/unblock-secret/38MFs1bIXxFccubFXqx7MdZlT3s
   ```

2. **Revisa los detalles**:
   - Verifica que está en archivos de ejemplo/documentación
   - Confirma que no es un secret crítico de producción

3. **Haz clic en "Allow secret"** o el botón equivalente

### Paso 2: Permitir Stripe Test API Secret Key

1. **Abre esta URL**:
   ```
   https://github.com/abrsanchezolea/AMEFA.Orchestration/security/secret-scanning/unblock-secret/38M21lJghpalGU4OnSjN8qqkOLJ
   ```

2. **Revisa los detalles**:
   - Verifica que está en archivos de ejemplo/documentación
   - Confirma que es una clave de **test** (no producción)

3. **Haz clic en "Allow secret"** o el botón equivalente

### Paso 3: Intentar Push Nuevamente

Después de permitir ambos secrets:

```bash
git push origin main
```

## ⚠️ Importante: Rotar Secretos Expuestos

**Aunque permitas el secret en GitHub, los secretos ya fueron expuestos y debes rotarlos:**

### 1. Docker Personal Access Token

1. Ve a: https://hub.docker.com/settings/security
2. Busca el token que comienza con `dckr_pat_PEMyxCOKpH-BMi1oNEcLkSQttac`
3. **Revócalo** (haz clic en "Revoke")
4. **Genera uno nuevo**:
   - Account Settings → Security → New Access Token
   - Copia el nuevo token
   - Actualiza el secret en GitHub: `DOCKER_PASSWORD`

### 2. Stripe Test Keys

1. Ve a: https://dashboard.stripe.com/test/apikeys
2. Busca las claves que fueron expuestas:
   - `sk_test_51SQut3PFLMaWWqfnxr0AFlb24kPEWoGks5kE5viCXzL0J8MAvZK9MUZth2TsUQXkwCsxx1RsLzdlxYnsIJunatsc00gy3X241t`
   - `pk_test_51SQut3PFLMaWWqfnMe5x7r1C6PJfA3oUPxdHp1VWWGHFJ3LnBW9dgD0KQtBtXv1qfx0hLRr8D0TXe2PAiEGjgHo7006ciMiPIt`
3. **Revócalas** (haz clic en "Revoke" en cada una)
4. **Genera nuevas claves de test**
5. **Actualiza los secrets en GitHub Environments**:
   - `STRIPE_SECRET_KEY` (en staging y production)
   - `STRIPE_PUBLISHABLE_KEY` (en staging y production)

## 🔒 Prevención Futura

1. **Nunca subas secretos reales al repositorio**
2. **Usa placeholders en archivos de ejemplo**:
   - `dckr_pat_PLACEHOLDER`
   - `sk_test_your_stripe_secret_key_here`
3. **Revisa antes de commit**:
   ```bash
   git diff --cached | grep -i "sk_test\|dckr_pat\|password"
   ```
4. **Usa `.gitignore`** para archivos con secretos:
   ```
   secrets-*.json
   !secrets-*.json.example
   ```

## 📝 Checklist

- [ ] Permitir Docker token en GitHub (URL 1)
- [ ] Permitir Stripe key en GitHub (URL 2)
- [ ] Intentar push nuevamente
- [ ] Rotar Docker token (revocar y generar nuevo)
- [ ] Rotar Stripe keys (revocar y generar nuevas)
- [ ] Actualizar secrets en GitHub Environments con los nuevos valores
- [ ] Verificar que el push funciona

## 🆘 Si No Puedes Permitir el Secret

Si no tienes permisos para permitir el secret o prefieres limpiar el historial:

Ver: `FIX_SECRETS_IN_HISTORY.md` para instrucciones sobre cómo limpiar el historial de Git.
