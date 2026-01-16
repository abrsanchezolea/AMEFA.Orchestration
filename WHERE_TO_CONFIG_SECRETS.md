# Dónde Configurar los GitHub Secrets

## 📍 Repositorio: AMEFA.Orchestration

Los GitHub Secrets deben configurarse en el repositorio **AMEFA.Orchestration** porque:

1. ✅ Todos los workflows están ubicados en `AMEFA.Orchestration/.github/workflows/`
2. ✅ Los workflows monitorean cambios en los otros proyectos usando paths relativos
3. ✅ Los workflows se ejecutan desde el contexto de AMEFA.Orchestration

## 🔍 Workflows que Usan los Secrets

Los siguientes workflows están en `AMEFA.Orchestration/.github/workflows/`:

- ✅ `deploy-api.yml` - Despliega AMEFAService.API
- ✅ `deploy-gateway.yml` - Despliega AMEFAService.Gateway  
- ✅ `deploy-web.yml` - Despliega AMEFA.Web
- ✅ `deploy-orchestration.yml` - Despliega todo el stack

## 📝 Cómo Configurar los Secrets

### Paso 1: Ir al Repositorio AMEFA.Orchestration

1. Ve a: `https://github.com/abrsanchezolea/AMEFA.Orchestration`

### Paso 2: Ir a Settings → Secrets

1. En el repositorio, haz clic en **Settings**
2. En el menú lateral, ve a **Secrets and variables** → **Actions**
3. Haz clic en **New repository secret**

### Paso 3: Agregar Cada Secret

Para cada secret listado en `GITHUB_SECRETS_SETUP.md`:

1. **Name**: El nombre del secret (ej: `DOCKER_USERNAME`)
2. **Secret**: El valor del secret (ej: `abrsanchez`)
3. Haz clic en **Add secret**

## 🔄 Estructura del Repositorio

### Estructura Actual:

```
AMEFA.Orchestration/ (repositorio separado en GitHub)
└── .github/
    └── workflows/
        ├── deploy-api.yml
        ├── deploy-gateway.yml
        ├── deploy-web.yml
        └── deploy-orchestration.yml
```

**Los secrets se configuran en**: `https://github.com/abrsanchezolea/AMEFA.Orchestration`

**Nota**: Los workflows monitorean cambios en otros proyectos usando paths relativos (`../AMEFAService.API/**`), pero los workflows se ejecutan desde el contexto de `AMEFA.Orchestration`, por lo que los secrets deben estar en este repositorio.

## ✅ Verificación

Para verificar que los secrets están configurados correctamente:

1. Ve a: **Settings** → **Secrets and variables** → **Actions**
2. Deberías ver todos los secrets listados
3. Los secrets aparecen como `••••••••` (ocultos por seguridad)

## 🆘 Troubleshooting

### El workflow no encuentra los secrets

- ✅ Verifica que estás en el repositorio correcto (AMEFA.Orchestration o el monorepo raíz)
- ✅ Verifica que el secret tiene el nombre exacto (case-sensitive)
- ✅ Verifica que tienes permisos de administrador en el repositorio

### No puedo ver/editar secrets

- ✅ Solo los administradores del repositorio pueden configurar secrets
- ✅ Si no eres administrador, contacta al dueño del repositorio

## 📚 Referencias

- [GitHub Docs: Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Docs: Using secrets in a workflow](https://docs.github.com/en/actions/security-guides/encrypted-secrets#using-encrypted-secrets-in-a-workflow)
