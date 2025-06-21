#!/bin/bash

# Script para verificar que todas las dependencias externas están ejecutándose
# PostgreSQL, Redis y la red prod_backend

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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
    echo -e "${BLUE}[HEADER]${NC} $1"
}

print_header "🔍 Verificando dependencias para Superset..."

# Función para verificar si un contenedor está ejecutándose
check_container() {
    local container_name="$1"
    local service_name="$2"
    
    if docker ps | grep -q "$container_name"; then
        print_message "✅ $service_name está ejecutándose ($container_name)"
        return 0
    else
        print_error "❌ $service_name NO está ejecutándose ($container_name)"
        return 1
    fi
}

# Función para verificar conectividad
test_connectivity() {
    local service="$1"
    local host="$2"
    local port="$3"
    
    print_message "🔍 Probando conectividad a $service..."
    
    case $service in
        "PostgreSQL")
            if docker run --rm --network prod_backend postgres:15 pg_isready -h "$host" -p "$port" -U postgres 2>/dev/null; then
                print_message "✅ $service responde correctamente"
                return 0
            else
                print_warning "⚠️  $service no responde o aún está iniciando"
                return 1
            fi
            ;;
        "Redis")
            if docker run --rm --network prod_backend redis:7-alpine redis-cli -h "$host" -p "$port" -a "CQhgg6uELsQQwUXA" ping 2>/dev/null | grep -q "PONG"; then
                print_message "✅ $service responde correctamente"
                return 0
            else
                print_warning "⚠️  $service no responde o aún está iniciando"
                return 1
            fi
            ;;
    esac
}

# Variables de control
postgres_running=false
redis_running=false
network_exists=false
connectivity_ok=true

print_header "📋 Estado de Servicios Externos"

# Verificar PostgreSQL
if check_container "postgres_prod" "PostgreSQL"; then
    postgres_running=true
fi

# Verificar Redis
if check_container "redis_prod" "Redis"; then
    redis_running=true
fi

print_header "🌐 Verificación de Red Docker"

# Verificar red prod_backend
if docker network ls | grep -q "prod_backend"; then
    print_message "✅ La red 'prod_backend' existe"
    network_exists=true
    
    # Verificar contenedores en la red
    print_message "📋 Contenedores en la red prod_backend:"
    docker network inspect prod_backend --format '{{range .Containers}}  - {{.Name}} ({{.IPv4Address}}){{"\n"}}{{end}}'
    
    # Verificar conectividad si los servicios están ejecutándose
    if $postgres_running; then
        test_connectivity "PostgreSQL" "postgres_prod" "5432" || connectivity_ok=false
    fi
    
    if $redis_running; then
        test_connectivity "Redis" "redis_prod" "6379" || connectivity_ok=false
    fi
else
    print_error "❌ La red 'prod_backend' no existe"
    network_exists=false
fi

print_header "📊 Resumen de Estado"

# Calcular estado general
all_good=true

if ! $postgres_running; then
    print_error "❌ PostgreSQL no está ejecutándose"
    all_good=false
fi

if ! $redis_running; then
    print_error "❌ Redis no está ejecutándose"
    all_good=false
fi

if ! $network_exists; then
    print_error "❌ Red Docker no configurada"
    all_good=false
fi

if ! $connectivity_ok; then
    print_warning "⚠️  Hay problemas de conectividad"
fi

if $all_good && $connectivity_ok; then
    print_message "🎉 ¡Todas las dependencias están listas para Superset!"
    echo ""
    print_message "Puedes ejecutar: ./setup-superset.sh start"
    exit 0
else
    print_error "🚨 Hay problemas que resolver antes de iniciar Superset"
    echo ""
    
    if ! $postgres_running; then
        print_message "Para iniciar PostgreSQL:"
        echo "  cd ~/automation/shared/postgres && docker compose up -d"
    fi
    
    if ! $redis_running; then
        print_message "Para iniciar Redis:"
        echo "  cd ~/automation/shared/redis && docker compose up -d"
    fi
    
    if ! $network_exists; then
        print_message "Para crear la red:"
        echo "  docker network create prod_backend"
    fi
    
    exit 1
fi