#!/bin/bash

# Script para verificar y configurar la red Docker para Superset
# Este script verifica que la red prod_backend existe y está accesible

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

print_message "🔍 Verificando configuración de red Docker..."

# Verificar que la red prod_backend existe
if docker network ls | grep -q "prod_backend"; then
    print_message "✅ La red 'prod_backend' existe"
else
    print_error "❌ La red 'prod_backend' no existe"
    print_message "Creando red 'prod_backend'..."
    docker network create prod_backend
    print_message "✅ Red 'prod_backend' creada"
fi

# Verificar que postgres_prod está en la red
if docker network inspect prod_backend | grep -q "postgres_prod"; then
    print_message "✅ El contenedor 'postgres_prod' está conectado a 'prod_backend'"
else
    print_warning "⚠️  El contenedor 'postgres_prod' no está en la red 'prod_backend'"
    
    # Verificar si postgres_prod existe
    if docker ps -a | grep -q "postgres_prod"; then
        print_message "Conectando postgres_prod a la red prod_backend..."
        docker network connect prod_backend postgres_prod
        print_message "✅ postgres_prod conectado a prod_backend"
    else
        print_error "❌ El contenedor 'postgres_prod' no existe"
        print_message "Por favor inicia PostgreSQL primero:"
        print_message "cd ~/automation/shared/postgres && docker compose up -d"
        exit 1
    fi
fi

# Verificar que redis_prod está en la red
if docker network inspect prod_backend | grep -q "redis_prod"; then
    print_message "✅ El contenedor 'redis_prod' está conectado a 'prod_backend'"
else
    print_warning "⚠️  El contenedor 'redis_prod' no está en la red 'prod_backend'"
    
    # Verificar si redis_prod existe
    if docker ps -a | grep -q "redis_prod"; then
        print_message "Conectando redis_prod a la red prod_backend..."
        docker network connect prod_backend redis_prod
        print_message "✅ redis_prod conectado a prod_backend"
    else
        print_error "❌ El contenedor 'redis_prod' no existe"
        print_message "Por favor inicia Redis primero:"
        print_message "cd ~/automation/shared/redis && docker compose up -d"
        exit 1
    fi
fi

# Mostrar información de la red
print_message "📋 Información de la red prod_backend:"
docker network inspect prod_backend --format '{{range .Containers}}Container: {{.Name}} - IP: {{.IPv4Address}}{{"\n"}}{{end}}'

# Verificar conectividad
print_message "🔍 Verificando conectividad a PostgreSQL..."
if docker run --rm --network prod_backend postgres:15 pg_isready -h postgres_prod -p 5432 -U postgres; then
    print_message "✅ PostgreSQL es accesible desde la red prod_backend"
else
    print_warning "⚠️  No se pudo verificar la conectividad a PostgreSQL"
    print_message "Esto puede ser normal si PostgreSQL aún no está completamente iniciado"
fi

print_message "🔍 Verificando conectividad a Redis..."
if docker run --rm --network prod_backend redis:7-alpine redis-cli -h redis_prod -p 6379 -a CQhgg6uELsQQwUXA ping | grep -q "PONG"; then
    print_message "✅ Redis es accesible desde la red prod_backend"
else
    print_warning "⚠️  No se pudo verificar la conectividad a Redis"
    print_message "Esto puede ser normal si Redis aún no está completamente iniciado"
fi

print_message "🚀 Configuración de red completada"