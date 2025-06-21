#!/bin/bash

# Script de inicialización personalizado para PostgreSQL
# Ejecuta la inicialización estándar y luego configuraciones adicionales

set -e

echo "Iniciando PostgreSQL con configuraciones personalizadas..."

# Ejecutar el entrypoint original de PostgreSQL
exec docker-entrypoint.sh "$@"