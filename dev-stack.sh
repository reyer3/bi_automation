#!/bin/bash

# Script para gestionar el stack completo de desarrollo
# PostgreSQL + Redis + Superset

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
    echo -e "${BLUE}=====================================
$1
=====================================${NC}"
}

# Verificar dependencias
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado"
        exit 1
    fi
    
    if ! command -v docker compose &> /dev/null; then
        print_error "Docker Compose no está disponible"
        exit 1
    fi
    
    print_message "Docker y Docker Compose disponibles"
}

# Configurar archivo .env si no existe
setup_env() {
    if [ ! -f .env ]; then
        print_message "Creando archivo .env desde template..."
        cp .env.dev .env
        
        # Generar SECRET_KEY única
        if command -v openssl &> /dev/null; then
            SECRET_KEY=$(openssl rand -base64 42)
            sed -i "s/your-very-strong-secret-key-change-this-in-production/$SECRET_KEY/g" .env
            print_message "SECRET_KEY generada automáticamente"
        else
            print_warning "OpenSSL no disponible. Por favor cambia SUPERSET_SECRET_KEY en .env"
        fi
    else
        print_message "Archivo .env ya existe"
    fi
}

# Iniciar stack completo
start_stack() {
    print_header "🚀 INICIANDO STACK COMPLETO DE DESARROLLO"
    
    print_message "Iniciando PostgreSQL..."
    docker compose -f docker-compose.dev.yml up -d postgres
    
    print_message "Esperando que PostgreSQL esté listo..."
    sleep 10
    
    print_message "Iniciando Redis..."
    docker compose -f docker-compose.dev.yml up -d redis
    
    print_message "Esperando que Redis esté listo..."
    sleep 5
    
    print_message "Inicializando base de datos de Superset..."
    docker compose -f docker-compose.dev.yml up superset-init
    
    print_message "Iniciando servicios de Superset..."
    docker compose -f docker-compose.dev.yml up -d superset superset-worker superset-worker-beat
    
    print_header "🎉 ¡STACK COMPLETO INICIADO!"
    echo ""
    print_message "📊 Superset disponible en: http://localhost:8088"
    print_message "👤 Usuario: admin"
    print_message "🔑 Contraseña: admin"
    print_message "🔍 PostgreSQL: localhost:5432 (postgres/a8Nci+MpaOcFYzSa)"
    print_message "🔴 Redis: localhost:6379 (password: CQhgg6uELsQQwUXA)"
    echo ""
    print_message "📋 Ver estado: ./dev-stack.sh status"
    print_message "📜 Ver logs: ./dev-stack.sh logs"
}

# Detener stack
stop_stack() {
    print_message "Deteniendo stack completo..."
    docker compose -f docker-compose.dev.yml down
    print_message "✅ Stack detenido"
}

# Reiniciar stack
restart_stack() {
    print_message "Reiniciando stack..."
    stop_stack
    sleep 2
    start_stack
}

# Ver estado
show_status() {
    print_header "📊 ESTADO DEL STACK"
    docker compose -f docker-compose.dev.yml ps
    
    echo ""
    print_header "🔍 HEALTH CHECKS"
    
    # Check PostgreSQL
    if docker exec postgres_prod pg_isready -U postgres &>/dev/null; then
        print_message "✅ PostgreSQL: Saludable"
    else
        print_error "❌ PostgreSQL: No responde"
    fi
    
    # Check Redis
    if docker exec redis_prod redis-cli -a CQhgg6uELsQQwUXA ping &>/dev/null | grep -q PONG; then
        print_message "✅ Redis: Saludable"
    else
        print_error "❌ Redis: No responde"
    fi
    
    # Check Superset
    if curl -s http://localhost:8088/health &>/dev/null; then
        print_message "✅ Superset: Saludable"
    else
        print_warning "⚠️  Superset: No responde (puede estar iniciando)"
    fi
}

# Ver logs
show_logs() {
    if [ -n "${2:-}" ]; then
        print_message "Mostrando logs de $2..."
        docker compose -f docker-compose.dev.yml logs -f "$2"
    else
        print_message "Mostrando logs de todos los servicios..."
        docker compose -f docker-compose.dev.yml logs -f
    fi
}

# Limpiar todo
cleanup() {
    print_warning "Esto eliminará todos los contenedores, volúmenes y datos."
    read -p "¿Estás seguro? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_message "Limpiando stack completo..."
        docker compose -f docker-compose.dev.yml down -v --remove-orphans
        docker system prune -f
        print_message "✅ Limpieza completada"
    else
        print_message "Operación cancelada"
    fi
}

# Actualizar imágenes
update_images() {
    print_message "Actualizando imágenes..."
    docker compose -f docker-compose.dev.yml pull
    docker compose -f docker-compose.dev.yml up -d
    print_message "✅ Imágenes actualizadas"
}

# Crear backup de PostgreSQL
backup_postgres() {
    local backup_file="backup_postgres_$(date +%Y%m%d_%H%M%S).sql"
    print_message "Creando backup de PostgreSQL..."
    
    docker exec postgres_prod pg_dumpall -U postgres > "$backup_file"
    print_message "✅ Backup creado: $backup_file"
}

# Conectar a PostgreSQL
connect_postgres() {
    print_message "Conectando a PostgreSQL..."
    docker exec -it postgres_prod psql -U postgres
}

# Conectar a Redis
connect_redis() {
    print_message "Conectando a Redis..."
    docker exec -it redis_prod redis-cli -a CQhgg6uELsQQwUXA
}

# Menú principal
print_header "🛠️  BI AUTOMATION - DEV STACK MANAGER"

case "${1:-help}" in
    "start")
        check_dependencies
        setup_env
        start_stack
        ;;
    "stop")
        stop_stack
        ;;
    "restart")
        check_dependencies
        restart_stack
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs "$@"
        ;;
    "cleanup")
        cleanup
        ;;
    "update")
        update_images
        ;;
    "backup")
        backup_postgres
        ;;
    "psql")
        connect_postgres
        ;;
    "redis")
        connect_redis
        ;;
    "help"|*)
        echo "Uso: $0 {comando}"
        echo ""
        echo "Comandos disponibles:"
        echo "  start      - Iniciar stack completo (PostgreSQL + Redis + Superset)"
        echo "  stop       - Detener todos los servicios"
        echo "  restart    - Reiniciar stack completo"
        echo "  status     - Mostrar estado y health checks"
        echo "  logs       - Mostrar logs (opcional: especificar servicio)"
        echo "  update     - Actualizar imágenes Docker"
        echo "  backup     - Crear backup completo de PostgreSQL"
        echo "  cleanup    - Limpiar contenedores y volúmenes (¡CUIDADO!)"
        echo "  psql       - Conectar a PostgreSQL interactivamente"
        echo "  redis      - Conectar a Redis interactivamente"
        echo "  help       - Mostrar esta ayuda"
        echo ""
        echo "Ejemplos:"
        echo "  $0 start                    # Iniciar todo"
        echo "  $0 logs superset           # Ver logs solo de Superset"
        echo "  $0 logs postgres           # Ver logs solo de PostgreSQL"
        echo ""
        echo "📚 Documentación completa en: README.md"
        ;;
esac