# Información del Repositorio

## 📍 Repositorio de GitHub

**URL del Repositorio**: `https://github.com/abrsanchezolea/AMEFA.Orchestration`

## 🔐 Dónde Configurar los Secrets

Todos los GitHub Secrets deben configurarse en:
**`https://github.com/abrsanchezolea/AMEFA.Orchestration`**

### Pasos para Configurar:

1. Ve a: `https://github.com/abrsanchezolea/AMEFA.Orchestration`
2. Haz clic en **Settings** (en la barra superior del repositorio)
3. En el menú lateral, ve a **Environments**
4. Crea dos environments: `staging` y `production`
5. En cada environment, configura los secrets correspondientes

### ⚠️ Importante

- ✅ Usa **"Environment secrets"** (NO "Repository secrets")
- ✅ Crea dos environments: `staging` y `production`
- ✅ Configura los secrets en cada environment con los valores correspondientes
- ✅ Algunos secrets comunes (DOCKER_USERNAME, VPS_HOST, etc.) van en **Repository secrets**

**Ver guía completa en**: `ENVIRONMENT_SECRETS_SETUP.md`

## 📁 Estructura del Proyecto

Los workflows están ubicados en:
```
AMEFA.Orchestration/
└── .github/
    └── workflows/
        ├── deploy-api.yml          → Despliega AMEFAService.API
        ├── deploy-gateway.yml      → Despliega AMEFAService.Gateway
        ├── deploy-web.yml          → Despliega AMEFA.Web
        └── deploy-orchestration.yml → Despliega todo el stack
```

## 🔄 Cómo Funcionan los Workflows

Los workflows monitorean cambios en otros proyectos usando paths relativos:
- `'../AMEFAService.API/**'` → Monitorea cambios en AMEFAService.API
- `'../AMEFAService.Gateway/**'` → Monitorea cambios en AMEFAService.Gateway
- `'../AMEFA.Web/**'` → Monitorea cambios en AMEFA.Web

**Importante**: Aunque los workflows monitorean otros proyectos, se ejecutan desde el contexto de `AMEFA.Orchestration`, por lo que:
- ✅ Los secrets deben estar en `AMEFA.Orchestration`
- ✅ Los workflows tienen acceso a los otros proyectos mediante paths relativos
- ✅ El checkout del código incluye los otros proyectos si están en el mismo workspace

## ✅ Verificación

Para verificar que estás en el repositorio correcto:

1. Ve a: `https://github.com/abrsanchezolea/AMEFA.Orchestration`
2. Haz clic en la pestaña **Actions**
3. Deberías ver los workflows:
   - Deploy AMEFAService.API
   - Deploy AMEFAService.Gateway
   - Deploy AMEFA.Web
   - Deploy Orchestration (Full Stack)

Si ves estos workflows, estás en el repositorio correcto para configurar los secrets.
