#!/bin/bash
# Script para configurar GitHub Secrets masivamente usando GitHub CLI
# Requiere: GitHub CLI (gh) instalado y autenticado

set -e

REPO="abrsanchezolea/AMEFA.Orchestration"

echo "🔐 Configurando GitHub Secrets masivamente"
echo "Repositorio: $REPO"
echo ""

# Verificar que gh CLI está instalado
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) no está instalado"
    echo "Instala desde: https://cli.github.com/"
    exit 1
fi

# Verificar autenticación
if ! gh auth status &> /dev/null; then
    echo "❌ Error: No estás autenticado en GitHub CLI"
    echo "Ejecuta: gh auth login"
    exit 1
fi

# Función para configurar secrets de un environment
setup_environment_secrets() {
    local ENV=$1
    local SECRETS_FILE=$2
    
    echo "📦 Configurando secrets para environment: $ENV"
    
    if [ ! -f "$SECRETS_FILE" ]; then
        echo "⚠️  Archivo no encontrado: $SECRETS_FILE"
        return
    fi
    
    # Leer JSON y configurar cada secret
    while IFS="=" read -r key value; do
        # Saltar comentarios y líneas vacías
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        
        # Limpiar espacios
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        if [ -n "$key" ] && [ -n "$value" ]; then
            echo "  → Configurando: $key"
            echo "$value" | gh secret set "$key" --env "$ENV" --repo "$REPO"
        fi
    done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' "$SECRETS_FILE" 2>/dev/null || cat "$SECRETS_FILE" | grep -v '^#' | grep '=')
    
    echo "✅ Secrets configurados para $ENV"
    echo ""
}

# Función para configurar repository secrets
setup_repository_secrets() {
    local SECRETS_FILE=$1
    
    echo "📦 Configurando Repository secrets"
    
    if [ ! -f "$SECRETS_FILE" ]; then
        echo "⚠️  Archivo no encontrado: $SECRETS_FILE"
        return
    fi
    
    # Leer JSON y configurar cada secret
    while IFS="=" read -r key value; do
        # Saltar comentarios y líneas vacías
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        
        # Limpiar espacios
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        if [ -n "$key" ] && [ -n "$value" ]; then
            echo "  → Configurando: $key"
            echo "$value" | gh secret set "$key" --repo "$REPO"
        fi
    done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' "$SECRETS_FILE" 2>/dev/null || cat "$SECRETS_FILE" | grep -v '^#' | grep '=')
    
    echo "✅ Repository secrets configurados"
    echo ""
}

# Verificar que los environments existen
echo "🔍 Verificando environments..."
gh api repos/$REPO/environments/staging &> /dev/null || {
    echo "⚠️  Environment 'staging' no existe. Creándolo..."
    gh api repos/$REPO/environments/staging -X PUT -f '{}' || true
}

gh api repos/$REPO/environments/production &> /dev/null || {
    echo "⚠️  Environment 'production' no existe. Creándolo..."
    gh api repos/$REPO/environments/production -X PUT -f '{}' || true
}

# Configurar secrets
if [ -f "secrets-staging.json" ]; then
    setup_environment_secrets "staging" "secrets-staging.json"
fi

if [ -f "secrets-production.json" ]; then
    setup_environment_secrets "production" "secrets-production.json"
fi

if [ -f "secrets-repository.json" ]; then
    setup_repository_secrets "secrets-repository.json"
fi

echo "✅ Configuración completada"
echo ""
echo "📝 Verifica los secrets en:"
echo "   https://github.com/$REPO/settings/environments"
