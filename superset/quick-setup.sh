#!/bin/bash

# Script de configuración express para Superset
# Este script automatiza todo el proceso de setup

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=====================================
$1
=====================================${NC}"
}

print_header "🚀 CONFIGURACIÓN EXPRESS DE SUPERSET"

print_message "Este script configurará Superset usando tus servicios PostgreSQL y Redis existentes"

# Verificar dependencias
print_header "📋 Verificando Dependencias"

if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado"
    exit 1
fi

if ! command -v openssl &> /dev/null; then
    print_error "OpenSSL no está instalado"
    exit 1
fi

print_message "✅ Docker y OpenSSL disponibles"

# Iniciar servicios externos
print_header "🏗️ Iniciando Servicios Externos"

print_message "Iniciando PostgreSQL..."
cd ~/automation/shared/postgres
docker compose up -d

print_message "Iniciando Redis..."
cd ~/automation/shared/redis
docker compose up -d

# Esperar que estén listos
print_message "Esperando que los servicios estén listos..."
sleep 10

# Volver al directorio de Superset
cd ~/superset-docker || {
    print_error "Directorio ~/superset-docker no existe. ¿Creaste la estructura de archivos?"
    exit 1
}

# Verificar archivos necesarios
print_header "📁 Verificando Archivos de Configuración"

required_files=(
    "docker-compose.yml"
    "setup-superset.sh"
    "docker/.env-non-dev"
    "docker/pythonpath_dev/superset_config_docker.py"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_message "✅ $file existe"
    else
        print_error "❌ $file no existe. Por favor crea este archivo."
        exit 1
    fi
done

# Hacer scripts ejecutables
chmod +x setup-superset.sh
[ -f scripts/check-dependencies.sh ] && chmod +x scripts/check-dependencies.sh
[ -f scripts/setup-superset-db.sh ] && chmod +x scripts/setup-superset-db.sh
[ -f scripts/setup-network.sh ] && chmod +x scripts/setup-network.sh

# Verificar dependencias externas
print_header "🔍 Verificando Servicios Externos"

if [ -f scripts/check-dependencies.sh ]; then
    if ./scripts/check-dependencies.sh; then
        print_message "✅ Todas las dependencias están listas"
    else
        print_error "❌ Hay problemas con las dependencias"
        exit 1
    fi
else
    print_warning "Script de verificación no encontrado, continuando..."
fi

# Configurar Superset
print_header "⚙️ Configurando Superset"

if ./setup-superset.sh start; then
    print_header "🎉 ¡CONFIGURACIÓN COMPLETADA!"
    echo ""
    print_message "📊 Superset está disponible en: http://localhost:8088"
    print_message "👤 Usuario: admin"
    print_message "🔑 Contraseña: admin"
    echo ""
    print_message "🛠️ Comandos útiles:"
    echo "  ./setup-superset.sh status    # Ver estado"
    echo "  ./setup-superset.sh logs      # Ver logs"
    echo "  ./setup-superset.sh deps      # Verificar dependencias"
    echo "  ./setup-superset.sh stop      # Detener servicios"
    echo ""
    print_message "📚 Consulta el README.md para más información"
else
    print_error "❌ Error durante la configuración de Superset"
    exit 1
fi