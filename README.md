# BI Automation - Superset Configuration

🚀 Configuración completa de Apache Superset usando infraestructura PostgreSQL y Redis existente

## 📋 Contenido del Repositorio

```
bi_automation/
└── superset/                    # Configuración de Apache Superset
    ├── docker-compose.yml       # Orquestación de servicios
    ├── setup-superset.sh        # Script principal de gestión
    ├── quick-setup.sh           # Configuración express
    ├── docker/
    │   ├── .env-non-dev         # Variables de entorno base
    │   ├── .env-local.template  # Template para variables locales
    │   └── pythonpath_dev/
    │       └── superset_config_docker.py  # Configuración avanzada
    ├── scripts/
    │   ├── setup-superset-db.sh    # Configuración de base de datos
    │   ├── setup-network.sh        # Verificación de red Docker
    │   └── check-dependencies.sh   # Verificación de dependencias
    └── README.md                   # Documentación completa
```

## 🏗️ Arquitectura

Esta configuración está diseñada para **reutilizar completamente** tu infraestructura existente:

- **PostgreSQL** (`postgres_prod`) - Para metadatos de Superset
- **Redis** (`redis_prod`) - Para cache y jobs asíncronos
- **Red Docker** (`prod_backend`) - Conectividad entre servicios

## ⚡ Quick Start

```bash
# Clonar repositorio
git clone https://github.com/reyer3/bi_automation.git
cd bi_automation/superset

# Configuración express (recomendado)
chmod +x quick-setup.sh
./quick-setup.sh

# Acceder a Superset
# URL: http://localhost:8088
# Usuario: admin
# Contraseña: admin
```

## 🛠️ Comandos Disponibles

```bash
./setup-superset.sh start      # Iniciar servicios
./setup-superset.sh stop       # Detener servicios
./setup-superset.sh status     # Ver estado
./setup-superset.sh logs       # Ver logs
./setup-superset.sh deps       # Verificar dependencias
./setup-superset.sh restart    # Reiniciar servicios
./setup-superset.sh update     # Actualizar imágenes
```

## 📚 Documentación

Consulta el `README.md` en el directorio `superset/` para:

- Guía completa de instalación
- Configuración avanzada
- Troubleshooting
- Personalización de features
- Conexión a bases de datos externas

## 🎯 Características Principales

✅ **Sin duplicación** - Usa PostgreSQL y Redis existentes  
✅ **Scripts automatizados** - Setup y gestión simplificada  
✅ **Verificación automática** - Dependencias y conectividad  
✅ **Configuración modular** - Fácil personalización  
✅ **Máximo rendimiento** - Mínimo uso de recursos  
✅ **Listo para escalar** - Base sólida para producción  

## 📄 Licencia

Este proyecto utiliza Apache Superset bajo licencia Apache 2.0.

---

**Desarrollado para automatización de Business Intelligence** 📊