# 🛠️ Entorno de Desarrollo Completo - BI Automation

Este documento describe cómo levantar un entorno de desarrollo completo con PostgreSQL, Redis y Superset usando Docker Compose.

## 🎯 **¿Qué Incluye Este Entorno?**

- **PostgreSQL 17** con TimescaleDB, pgvector y SSL
- **Redis 7** con autenticación y persistencia
- **Apache Superset** con configuración completa
- **Scripts automatizados** para gestión fácil
- **Configuración de desarrollo** lista para usar

## 🚀 **Quick Start (2 minutos)**

```bash
# 1. Clonar repositorio
git clone https://github.com/reyer3/bi_automation.git
cd bi_automation

# 2. Iniciar stack completo
chmod +x dev-stack.sh
./dev-stack.sh start

# 3. Acceder a los servicios
# Superset: http://localhost:8088 (admin/admin)
# PostgreSQL: localhost:5432 (postgres/a8Nci+MpaOcFYzSa)
# Redis: localhost:6379 (password: CQhgg6uELsQQwUXA)
```

## 📋 **Estructura del Entorno**

```
bi_automation/
├── docker-compose.dev.yml      # Orquestación completa
├── dev-stack.sh               # Script de gestión principal
├── .env.dev                   # Template de variables
├── shared/
│   ├── postgres/              # PostgreSQL con extensiones
│   │   ├── docker-compose.yml
│   │   ├── postgres.Dockerfile
│   │   ├── .env
│   │   ├── init/              # Scripts de inicialización
│   │   └── ssl/               # Certificados SSL
│   └── redis/                 # Redis con persistencia
│       ├── docker-compose.yml
│       ├── .env
│       └── data/              # Datos persistentes
└── superset/                  # Configuración de Superset
    └── [toda la configuración existente]
```

## ⚙️ **Comandos del Dev Stack**

### Gestión Básica
```bash
./dev-stack.sh start      # Iniciar stack completo
./dev-stack.sh stop       # Detener servicios
./dev-stack.sh restart    # Reiniciar todo
./dev-stack.sh status     # Ver estado y health checks
```

### Monitoreo y Debug
```bash
./dev-stack.sh logs           # Ver todos los logs
./dev-stack.sh logs postgres  # Ver logs específicos
./dev-stack.sh logs superset  # Ver logs de Superset
./dev-stack.sh logs redis     # Ver logs de Redis
```

### Mantenimiento
```bash
./dev-stack.sh update     # Actualizar imágenes
./dev-stack.sh backup     # Backup de PostgreSQL
./dev-stack.sh cleanup    # Limpiar todo (¡cuidado!)
```

### Conexiones Directas
```bash
./dev-stack.sh psql       # Conectar a PostgreSQL
./dev-stack.sh redis      # Conectar a Redis
```

## 🗄️ **Bases de Datos Configuradas**

PostgreSQL incluye estas bases de datos por defecto:
- `postgres` - Base de datos principal
- `superset` - Metadatos de Superset
- `n8n_database` - Para automatización
- `evolution_database` - Para WhatsApp API
- `chatwoot` - Para gestión de chat
- `talento_chats` - Para gestión de talentos

## 🔧 **Configuración Personalizada**

### Variables de Entorno

Copia y personaliza el archivo de entorno:
```bash
cp .env.dev .env
nano .env  # Editar según necesidades
```

**Variables principales:**
```bash
# PostgreSQL
POSTGRES_PASSWORD=a8Nci+MpaOcFYzSa

# Redis
REDIS_PASSWORD=CQhgg6uELsQQwUXA

# Superset
SUPERSET_SECRET_KEY=tu-clave-secreta-aqui
SUPERSET_LOAD_EXAMPLES=yes

# Opcional
MAPBOX_API_KEY=tu-api-key-mapbox
```

### Personalización de PostgreSQL

Edita `shared/postgres/init/` para agregar:
- Más bases de datos
- Usuarios adicionales
- Extensiones específicas
- Configuraciones personalizadas

### Personalización de Superset

Edita `superset/docker/pythonpath_dev/superset_config_docker.py` para:
- Configurar OAuth/LDAP
- Habilitar feature flags
- Ajustar límites y timeouts
- Configurar alertas y reportes

## 🌐 **Acceso a los Servicios**

| Servicio | URL/Conexión | Credenciales |
|----------|--------------|-------------|
| **Superset** | http://localhost:8088 | admin / admin |
| **PostgreSQL** | localhost:5432 | postgres / a8Nci+MpaOcFYzSa |
| **Redis** | localhost:6379 | password: CQhgg6uELsQQwUXA |

## 📊 **Configurar Conexiones en Superset**

### PostgreSQL (mismo servidor)
```
postgresql://postgres:a8Nci+MpaOcFYzSa@postgres_prod:5432/nombre_base_datos
```

### Bases de datos externas
```bash
# MySQL en otro contenedor
mysql://user:pass@mysql_container:3306/database

# PostgreSQL en host (Linux)
postgresql://user:pass@172.20.0.1:5432/database

# PostgreSQL en host (macOS/Windows)
postgresql://user:pass@host.docker.internal:5432/database
```

## 🚨 **Troubleshooting**

### El stack no inicia
```bash
# Verificar Docker
docker --version
docker compose version

# Verificar puertos disponibles
sudo netstat -tlnp | grep -E ":(5432|6379|8088)"

# Limpiar y reintentar
./dev-stack.sh cleanup
./dev-stack.sh start
```

### Problemas de conexión
```bash
# Verificar red Docker
docker network ls | grep prod_backend

# Recrear red si es necesario
docker network rm prod_backend
docker network create prod_backend

# Verificar health checks
./dev-stack.sh status
```

### PostgreSQL no inicia
```bash
# Ver logs específicos
./dev-stack.sh logs postgres

# Verificar permisos de volumen
docker volume inspect bi_automation_postgres_data

# Recrear volumen si es necesario
docker volume rm bi_automation_postgres_data
```

### Superset no puede conectar a PostgreSQL
```bash
# Verificar que PostgreSQL esté listo
docker exec postgres_prod pg_isready -U postgres

# Verificar conectividad desde Superset
docker exec superset_app pg_isready -h postgres_prod -p 5432 -U postgres

# Reiniciar servicios en orden
./dev-stack.sh stop
./dev-stack.sh start
```

## 🔒 **Consideraciones de Seguridad**

### Para Desarrollo ✅
- Contraseñas fijas están bien
- SSL auto-firmado es suficiente
- Logs de debug son útiles
- Puertos expuestos en localhost únicamente

### Para Producción ❌
- **NO usar estas configuraciones en producción**
- Cambiar todas las contraseñas
- Usar certificados SSL válidos
- Configurar firewalls y VPNs
- Habilitar logs de auditoría

## 📈 **Uso de Recursos**

### Mínimo Recomendado
- **RAM**: 8GB total (4GB para Docker)
- **CPU**: 4 cores
- **Disco**: 10GB libres

### Asignación por Servicio
- **PostgreSQL**: 2-4GB RAM
- **Redis**: 1-2GB RAM
- **Superset**: 1-2GB RAM
- **Sistema**: 2-4GB RAM

### Optimización
```bash
# En .env, ajustar según tu hardware
POSTGRES_MEMORY_LIMIT=2G
REDIS_MEMORY_LIMIT=1G
SUPERSET_WORKERS=2
```

## 🎓 **Flujo de Desarrollo Típico**

### 1. Desarrollo Inicial
```bash
# Iniciar entorno limpio
./dev-stack.sh start

# Conectar bases de datos en Superset
# Crear dashboards de prueba
# Configurar usuarios y permisos
```

### 2. Desarrollo Diario
```bash
# Ver estado
./dev-stack.sh status

# Ver logs en caso de problemas
./dev-stack.sh logs superset

# Backup antes de cambios importantes
./dev-stack.sh backup
```

### 3. Testing y Validación
```bash
# Limpiar y probar desde cero
./dev-stack.sh cleanup
./dev-stack.sh start

# Validar configuraciones
./dev-stack.sh status
```

## 🚀 **Siguientes Pasos**

1. **Configurar conexiones** a tus bases de datos
2. **Importar dashboards** existentes
3. **Crear usuarios** para tu equipo
4. **Configurar alertas** y reportes automatizados
5. **Personalizar tema** y branding
6. **Implementar OAuth/LDAP** para SSO

## 📚 **Referencias Adicionales**

- [Configuración avanzada de Superset](./superset/README.md)
- [Documentación oficial de Superset](https://superset.apache.org/)
- [PostgreSQL con TimescaleDB](https://docs.timescale.com/)
- [Redis Configuration](https://redis.io/docs/manual/config/)

---

**¡Tu entorno de desarrollo completo está listo para crear dashboards increíbles!** 📊✨