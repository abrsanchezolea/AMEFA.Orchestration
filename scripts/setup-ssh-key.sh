#!/bin/bash
# Script para generar y configurar clave SSH para GitHub Actions

set -e

echo "🔐 Generando clave SSH para GitHub Actions..."
echo ""

# Generar clave SSH sin passphrase
KEY_NAME="github_actions"
KEY_PATH="$HOME/.ssh/$KEY_NAME"

if [ -f "$KEY_PATH" ]; then
    echo "⚠️  La clave $KEY_PATH ya existe."
    read -p "¿Deseas sobrescribirla? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "❌ Operación cancelada"
        exit 1
    fi
    rm -f "$KEY_PATH" "$KEY_PATH.pub"
fi

# Generar clave
echo "📝 Generando clave SSH..."
ssh-keygen -t ed25519 -C "github-actions-deploy" -f "$KEY_PATH" -N ""

echo ""
echo "✅ Clave generada exitosamente"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 CLAVE PÚBLICA (copia esto al VPS):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$KEY_PATH.pub"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Preguntar si quiere copiar automáticamente al VPS
read -p "¿Deseas copiar la clave pública al VPS automáticamente? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    read -p "Ingresa la IP o hostname del VPS: " VPS_HOST
    read -p "Ingresa el usuario SSH (default: root): " VPS_USER
    VPS_USER=${VPS_USER:-root}
    
    echo "📤 Copiando clave pública al VPS..."
    ssh-copy-id -i "$KEY_PATH.pub" "$VPS_USER@$VPS_HOST" || {
        echo "⚠️  No se pudo copiar automáticamente. Copia manualmente:"
        echo ""
        echo "ssh $VPS_USER@$VPS_HOST"
        echo "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
        echo "echo '$(cat $KEY_PATH.pub)' >> ~/.ssh/authorized_keys"
        echo "chmod 600 ~/.ssh/authorized_keys"
    }
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔑 CLAVE PRIVADA (copia esto a GitHub Secrets -> VPS_SSH_KEY):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$KEY_PATH"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Próximos pasos:"
echo "1. Copia la clave PRIVADA de arriba"
echo "2. Ve a: https://github.com/abrsanchezolea/AMEFA.Orchestration/settings/secrets/actions"
echo "3. Edita o crea el secret 'VPS_SSH_KEY' y pega la clave privada"
echo "4. Si la clave tiene passphrase, crea 'VPS_SSH_PASSPHRASE' (si no, déjalo vacío)"
echo ""
echo "✅ Configuración completada"
