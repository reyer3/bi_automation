#!/bin/bash

# Superset Docker Setup Script
# Este script configura automáticamente el entorno para Superset

set -e

echo "🚀 Configurando Superset con Docker Compose..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con color
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Por favor instala Docker primero."
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    print_error "Docker Compose no está disponible. Por favor instala Docker Compose."
    exit 1
fi

# Crear estructura de directorios
print_message "Creando estructura de directorios..."
mkdir -p docker/pythonpath_dev
mkdir -p scripts

# Generar SECRET_KEY si no existe
if [ ! -f docker/.env-local ]; then
    print_message "Generando SECRET_KEY..."
    SECRET_KEY=$(openssl rand -base64 42)
    
    # Crear archivo .env-local con la secret key generada
    cat > docker/.env-local << EOF
# Override default environment variables here
SUPERSET_SECRET_KEY=${SECRET_KEY}
SUPERSET_LOAD_EXAMPLES=yes
SUPERSET_PORT=8088
EOF
    print_message "Archivo docker/.env-local creado con SECRET_KEY generada"
else
    print_warning "El archivo docker/.env-local ya existe. No se modificará."
fi

# Verificar que los archivos necesarios existen
if [ ! -f docker/.env-non-dev ]; then
    print_error "El archivo docker/.env-non-dev no existe. Por favor créalo usando el template proporcionado."
    exit 1
fi

# Función para levantar los servicios
start_services() {
    print_message "Iniciando servicios de Superset..."
    
    # Verificar dependencias externas
    if [ -f scripts/check-dependencies.sh ]; then
        print_message "Verificando dependencias externas..."
        chmod +x scripts/check-dependencies.sh
        if ! ./scripts/check-dependencies.sh; then
            print_error "Las dependencias externas no están listas"
            exit 1
        fi
    else
        # Verificaciones básicas si no existe el script completo
        if ! docker ps | grep -q "postgres_prod"; then
            print_error "PostgreSQL externo (postgres_prod) no está ejecutándose."
            print_message "Por favor inicia PostgreSQL primero:"
            print_message "cd ~/automation/shared/postgres && docker compose up -d"
            exit 1
        fi
        
        if ! docker ps | grep -q "redis_prod"; then
            print_error "Redis externo (redis_prod) no está ejecutándose."
            print_message "Por favor inicia Redis primero:"
            print_message "cd ~/automation/shared/redis && docker compose up -d"
            exit 1
        fi
    fi
    
    # Verificar configuración de red
    if [ -f scripts/setup-network.sh ]; then
        print_message "Verificando configuración de red..."
        chmod +x scripts/setup-network.sh
        ./scripts/setup-network.sh
    fi
    
    # Verificar si hay contenedores ejecutándose
    if docker compose ps -q | grep -q .; then
        print_warning "Algunos contenedores ya están ejecutándose. Deteniendo..."
        docker compose down
    fi
    
    # Configurar base de datos de Superset si el script existe
    if [ -f scripts/setup-superset-db.sh ]; then
        print_message "Configurando base de datos de Superset..."
        chmod +x scripts/setup-superset-db.sh
        ./scripts/setup-superset-db.sh
    fi
    
    # Esperar un momento para que los servicios externos estén listos
    sleep 3
    
    # Inicializar Superset
    print_message "Inicializando Superset (esto puede tomar varios minutos)..."
    docker compose up superset-init
    
    # Iniciar todos los servicios
    print_message "Iniciando todos los servicios..."
    docker compose up -d
    
    print_message "✅ Superset está iniciando..."
    print_message "📊 Accede a Superset en: http://localhost:8088"
    print_message "👤 Usuario: admin"
    print_message "🔑 Contraseña: admin"
    print_message ""
    print_message "📋 Para ver los logs: docker compose logs -f"
    print_message "🛑 Para detener: docker compose down"
}

# Función para mostrar el estado
show_status() {
    print_message "Estado de los servicios:"
    docker compose ps
}

# Función para mostrar logs
show_logs() {
    docker compose logs -f
}

# Función para limpiar todo
cleanup() {
    print_warning "Esto eliminará todos los contenedores, volúmenes y datos de Superset."
    read -p "¿Estás seguro? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_message "Limpiando..."
        docker compose down -v --remove-orphans
        docker system prune -f
        print_message "✅ Limpieza completada"
    else
        print_message "Operación cancelada"
    fi
}

# Menu principal
case "${1:-start}" in
    "start")
        start_services
        ;;
    "stop")
        print_message "Deteniendo servicios..."
        docker compose down
        ;;
    "restart")
        print_message "Reiniciando servicios..."
        docker compose down
        start_services
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "cleanup")
        cleanup
        ;;
    "update")
        print_message "Actualizando imágenes..."
        docker compose pull
        docker compose up -d
        ;;
    "deps"|"dependencies")
        if [ -f scripts/check-dependencies.sh ]; then
            chmod +x scripts/check-dependencies.sh
            ./scripts/check-dependencies.sh
        else
            print_error "Script de verificación de dependencias no encontrado"
        fi
        ;;
    *)
        echo "Uso: $0 {start|stop|restart|status|logs|cleanup|update|deps}"
        echo ""
        echo "Comandos disponibles:"
        echo "  start      - Iniciar Superset (por defecto)"
        echo "  stop       - Detener todos los servicios"
        echo "  restart    - Reiniciar todos los servicios"
        echo "  status     - Mostrar estado de los servicios"
        echo "  logs       - Mostrar logs en tiempo real"
        echo "  cleanup    - Limpiar todos los contenedores y volúmenes"
        echo "  update     - Actualizar imágenes y reiniciar"
        echo "  deps       - Verificar dependencias externas (PostgreSQL, Redis)"
        exit 1
        ;;
esac