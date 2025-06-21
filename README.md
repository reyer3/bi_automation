# BI Automation - Superset Configuration

🚀 Configuración completa de Apache Superset usando infraestructura PostgreSQL y Redis existente

## 📋 Dos Opciones de Implementación

### 🏢 **Opción 1: Usando Infraestructura Existente** (Recomendado para Producción)
Utiliza tus servicios PostgreSQL y Redis ya configurados
- **Directorio**: `superset/`
- **Para**: Entornos donde ya tienes PostgreSQL y Redis corriendo
- **Ventaja**: Máxima eficiencia, reutilización total de infraestructura

### 🛠️ **Opción 2: Entorno de Desarrollo Completo** (Recomendado para Dev/Testing)
Stack completo con PostgreSQL, Redis y Superset desde cero
- **Directorio**: Raíz del proyecto (`docker-compose.dev.yml`)
- **Para**: Desarrollo, testing, demostraciones
- **Ventaja**: Setup en 2 minutos, entorno aislado y reproducible

---

## 🚀 Quick Start

### Para Infraestructura Existente
```bash
git clone https://github.com/reyer3/bi_automation.git
cd bi_automation/superset
chmod +x quick-setup.sh
./quick-setup.sh
```

### Para Entorno de Desarrollo Completo
```bash
git clone https://github.com/reyer3/bi_automation.git
cd bi_automation
chmod +x dev-stack.sh
./dev-stack.sh start
```

**Acceso a Superset:**
- URL: http://localhost:8088
- Usuario: `admin`
- Contraseña: `admin`

---

## 📁 Estructura del Repositorio

```
bi_automation/
├── 📚 README.md                    # Este archivo
├── 🚀 DEV_ENVIRONMENT.md           # Guía del entorno de desarrollo
├── 📋 IMPLEMENTATION_SUMMARY.md    # Resumen ejecutivo
├── 
├── 🛠️  ENTORNO DE DESARROLLO COMPLETO
├── docker-compose.dev.yml          # Stack completo (PostgreSQL + Redis + Superset)
├── dev-stack.sh                    # Script de gestión del entorno completo
├── .env.dev                        # Template de variables de entorno
├── shared/
│   ├── postgres/                   # PostgreSQL con TimescaleDB y extensiones
│   │   ├── docker-compose.yml
│   │   ├── postgres.Dockerfile
│   │   ├── .env
│   │   └── init/                   # Scripts de inicialización
│   └── redis/                      # Redis con autenticación y persistencia
│       ├── docker-compose.yml
│       ├── .env
│       └── data/                   # Datos persistentes
│
└── 🏢 SUPERSET PARA INFRAESTRUCTURA EXISTENTE
    └── superset/                   # Configuración optimizada de Superset
        ├── docker-compose.yml      # Solo servicios de Superset
        ├── quick-setup.sh          # Setup automático express
        ├── setup-superset.sh       # Gestión completa de servicios
        ├── docker/
        │   ├── .env-non-dev        # Variables configuradas
        │   ├── .env-local.template # Template personalizable
        │   └── pythonpath_dev/
        │       └── superset_config_docker.py
        ├── scripts/
        │   ├── check-dependencies.sh
        │   ├── setup-superset-db.sh
        │   └── setup-network.sh
        └── README.md               # Documentación detallada
```

---

## 🎯 Características Principales

### ✨ **Entorno de Desarrollo Completo**
- **Stack completo** - PostgreSQL 17 + Redis 7 + Superset
- **Setup en 2 minutos** - Un comando y todo funciona
- **Configuración enterprise** - TimescaleDB, pgvector, SSL
- **Bases de datos múltiples** - Pre-configuradas para diferentes proyectos
- **Scripts inteligentes** - Gestión automatizada con health checks

### 🏢 **Para Infraestructura Existente**  
- **Reutilización total** - Usa tu PostgreSQL y Redis existentes
- **Cero conflictos** - Integración perfecta con servicios actuales
- **Máximo rendimiento** - Sin duplicación de recursos
- **Configuración modular** - Fácil personalización y mantenimiento
- **Scripts automatizados** - Verificación y configuración automática

---

## 🛠️ Comandos Principales

### Entorno de Desarrollo Completo
```bash
./dev-stack.sh start      # Iniciar stack completo
./dev-stack.sh stop       # Detener servicios  
./dev-stack.sh status     # Ver estado y health checks
./dev-stack.sh logs       # Ver logs en tiempo real
./dev-stack.sh backup     # Backup de PostgreSQL
./dev-stack.sh psql       # Conectar a PostgreSQL
./dev-stack.sh redis      # Conectar a Redis
```

### Superset con Infraestructura Existente
```bash
./setup-superset.sh start    # Iniciar Superset
./setup-superset.sh deps     # Verificar dependencias
./setup-superset.sh status   # Ver estado
./setup-superset.sh logs     # Ver logs
```

---

## 🌐 Acceso a Servicios

| Servicio | URL/Conexión | Credenciales |
|----------|--------------|-------------|
| **Superset** | http://localhost:8088 | admin / admin |
| **PostgreSQL** | localhost:5432 | postgres / a8Nci+MpaOcFYzSa |
| **Redis** | localhost:6379 | password: CQhgg6uELsQQwUXA |

---

## 📊 Bases de Datos Incluidas

El entorno de desarrollo incluye estas bases de datos por defecto:
- `postgres` - Base de datos principal
- `superset` - Metadatos de Superset  
- `n8n_database` - Para automatización
- `evolution_database` - Para WhatsApp API
- `chatwoot` - Para gestión de chat
- `talento_chats` - Para gestión de talentos

---

## 🎯 Casos de Uso

### 👨‍💻 **Desarrolladores**
```bash
# Entorno completo para desarrollo
./dev-stack.sh start
# ¡Todo listo en 2 minutos!
```

### 🏢 **Equipos con Infraestructura Existente**  
```bash
# Usar PostgreSQL y Redis existentes
cd superset/
./quick-setup.sh
# Integración perfecta con servicios actuales
```

### 🧪 **Testing y Demos**
```bash
# Entorno aislado y reproducible
./dev-stack.sh start
# Perfecto para pruebas y demostraciones
```

### 📊 **Analistas de Datos**
```bash
# Conectar bases de datos existentes
# Crear dashboards y reportes
# Configurar alertas automatizadas
```

---

## 📚 Documentación Completa

- **[🛠️ Entorno de Desarrollo](DEV_ENVIRONMENT.md)** - Guía completa del stack de desarrollo
- **[🏢 Superset con Infraestructura Existente](superset/README.md)** - Documentación detallada
- **[📋 Resumen de Implementación](IMPLEMENTATION_SUMMARY.md)** - Overview ejecutivo
- **[🔧 Issue con Instrucciones](https://github.com/reyer3/bi_automation/issues/1)** - Guía paso a paso

---

## 💡 Ventajas Técnicas

### 🔧 **Infraestructura Optimizada**
- **PostgreSQL 17** con TimescaleDB y pgvector
- **Redis 7** con autenticación y persistencia AOF
- **Apache Superset** con configuración enterprise
- **Docker Compose** con health checks y dependencias

### ⚡ **Performance y Escalabilidad**
- **Recursos optimizados** - Configuración eficiente de memoria
- **Redes Docker** - Comunicación interna optimizada  
- **Volúmenes persistentes** - Datos seguros y backup automático
- **Health checks** - Monitoreo automático de servicios

### 🛡️ **Seguridad y Configuración**
- **SSL/TLS** - Certificados auto-firmados para desarrollo
- **Autenticación** - Redis con password, PostgreSQL con usuarios
- **Configuración modular** - Fácil personalización por entorno
- **Secretos gestionados** - Variables de entorno seguras

---

## 🚀 Próximos Pasos

1. **Elegir tu opción** - Infraestructura existente vs entorno completo
2. **Ejecutar quick start** - 2 minutos hasta tener Superset funcionando
3. **Conectar bases de datos** - Agregar tus fuentes de datos
4. **Crear dashboards** - Comenzar con visualizaciones
5. **Configurar usuarios** - Setup de permisos y roles
6. **Automatizar reportes** - Configurar alertas y reports

---

## 🤝 Soporte y Contribuciones

- **Issues**: https://github.com/reyer3/bi_automation/issues
- **Documentación**: Consultar archivos README específicos
- **Mejoras**: Pull requests bienvenidos

---

**Desarrollado con metodología sistemática y enfoque en reutilización de infraestructura existente** 🎯✨

**¡Tu plataforma de Business Intelligence está lista para generar insights!** 📊🚀