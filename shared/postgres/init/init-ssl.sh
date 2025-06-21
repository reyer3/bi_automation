#!/bin/bash

set -e

# Script para configurar SSL básico en PostgreSQL
# Para desarrollo - no usar en producción

echo "Configurando SSL para PostgreSQL..."

# Crear certificados auto-firmados si no existen
if [ ! -f "/var/lib/postgresql/ssl/server.crt" ]; then
    echo "Generando certificados SSL auto-firmados..."
    
    mkdir -p /var/lib/postgresql/ssl
    
    # Generar clave privada
    openssl genrsa -out /var/lib/postgresql/ssl/server.key 2048
    
    # Generar certificado auto-firmado
    openssl req -new -x509 -key /var/lib/postgresql/ssl/server.key \
        -out /var/lib/postgresql/ssl/server.crt \
        -days 365 \
        -subj "/C=PE/ST=Lima/L=Lima/O=Development/OU=IT/CN=postgres_dev"
    
    # Configurar permisos
    chmod 600 /var/lib/postgresql/ssl/server.key
    chmod 644 /var/lib/postgresql/ssl/server.crt
    
    chown postgres:postgres /var/lib/postgresql/ssl/server.key
    chown postgres:postgres /var/lib/postgresql/ssl/server.crt
    
    echo "Certificados SSL generados"
fi

# Configurar PostgreSQL para usar SSL
echo "ssl = on" >> "$PGDATA/postgresql.conf"
echo "ssl_cert_file = '/var/lib/postgresql/ssl/server.crt'" >> "$PGDATA/postgresql.conf"
echo "ssl_key_file = '/var/lib/postgresql/ssl/server.key'" >> "$PGDATA/postgresql.conf"

echo "SSL configurado para PostgreSQL"