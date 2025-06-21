#!/bin/bash

# Script para configurar la base de datos de Superset en PostgreSQL existente
# Este script crea la base de datos 'superset' en tu instancia PostgreSQL

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

# Configuración de la base de datos (ajusta según tu setup)
POSTGRES_HOST="localhost"
POSTGRES_PORT="5432"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="a8Nci+MpaOcFYzSa"
SUPERSET_DB="superset"

print_message "🔧 Configurando base de datos para Superset..."

# Verificar si PostgreSQL está ejecutándose
if ! docker ps | grep -q "postgres_prod"; then
    print_error "El contenedor postgres_prod no está ejecutándose."
    print_message "Por favor inicia PostgreSQL primero:"
    print_message "cd ~/automation/shared/postgres && docker compose up -d"
    exit 1
fi

# Función para ejecutar comandos SQL
execute_sql() {
    local sql="$1"
    docker exec -i postgres_prod psql -U postgres -c "$sql"
}

# Crear base de datos superset si no existe
print_message "Creando base de datos 'superset'..."
execute_sql "SELECT 'CREATE DATABASE $SUPERSET_DB' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$SUPERSET_DB')\\gexec" || {
    print_warning "La base de datos 'superset' ya existe o hubo un error al crearla"
}

# Verificar que la base de datos fue creada
if execute_sql "SELECT 1 FROM pg_database WHERE datname = '$SUPERSET_DB';" | grep -q "1"; then
    print_message "✅ Base de datos 'superset' configurada correctamente"
else
    print_error "❌ Error al configurar la base de datos"
    exit 1
fi

# Habilitar extensiones necesarias en la base de datos superset
print_message "Configurando extensiones necesarias..."
docker exec -i postgres_prod psql -U postgres -d superset << 'EOF'
-- Habilitar extensiones útiles para Superset
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Configurar permisos básicos
GRANT ALL PRIVILEGES ON DATABASE superset TO postgres;
EOF

print_message "✅ Extensiones configuradas correctamente"

# Mostrar información de conexión
print_message "📋 Información de conexión para Superset:"
echo "  Host: postgres_prod (desde containers Docker)"
echo "  Puerto: 5432"
echo "  Base de datos: superset"
echo "  Usuario: postgres"
echo "  Contraseña: a8Nci+MpaOcFYzSa"

print_message "🚀 La base de datos está lista para Superset"
print_message "Ahora puedes ejecutar: ./setup-superset.sh start"