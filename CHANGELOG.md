# Changelog - Orquestación Docker

## [1.0.0] - 2026-01-16

### Agregado
- ✅ Docker Compose para orquestar todos los servicios (SQL Server, API, Gateway, Web)
- ✅ Configuración de health checks para todos los servicios
- ✅ Variables de entorno configurables mediante archivo `.env`
- ✅ GitHub Actions workflows para deployment automático:
  - `deploy-web.yml` - Deployment automático de AMEFA.Web
  - `deploy-api.yml` - Deployment automático de AMEFAService.API
  - `deploy-gateway.yml` - Deployment automático de AMEFAService.Gateway
  - `deploy-orchestration.yml` - Deployment completo del stack
- ✅ Script de deployment (`deploy.sh`) para ejecución manual
- ✅ Documentación completa:
  - `README.md` - Documentación principal
  - `DEPLOYMENT.md` - Guía detallada de deployment
  - `QUICK_START.md` - Guía rápida de inicio
  - `env.example` - Ejemplo de variables de entorno
- ✅ Soporte para imágenes del registry Docker Hub
- ✅ Configuración de red Docker para comunicación entre servicios
- ✅ Volúmenes persistentes para la base de datos

### Características
- **Deployment Automático**: Los cambios en cada proyecto activan automáticamente el deployment
- **Health Checks**: Todos los servicios tienen health checks configurados
- **Dependencias**: Los servicios se inician en el orden correcto (SQL Server → API → Gateway → Web)
- **Flexibilidad**: Soporta construcción local o uso de imágenes del registry
- **Seguridad**: Variables sensibles mediante archivo `.env` (no versionado)

### Configuración Requerida
- Docker y Docker Compose en el VPS
- Secrets de GitHub configurados (DOCKER_USERNAME, DOCKER_PASSWORD, VPS_HOST, etc.)
- Archivo `.env` configurado en el VPS con todas las variables necesarias

### Próximas Mejoras Sugeridas
- [ ] Configuración de Nginx como reverse proxy
- [ ] Configuración de Let's Encrypt para HTTPS
- [ ] Monitoreo con Prometheus/Grafana
- [ ] Backup automático de la base de datos
- [ ] Logs centralizados con ELK Stack
- [ ] Configuración de CI/CD para múltiples ambientes (dev, staging, prod)
