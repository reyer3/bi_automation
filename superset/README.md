# Superset Docker Setup

Este proyecto configura Apache Superset usando Docker Compose para un entorno de desarrollo/testing robusto y escalable.

## 📋 Requisitos Previos

- Docker Desktop instalado
- PostgreSQL existente ejecutándose (postgres_prod container)
- Redis existente ejecutándose (redis_prod container)
- Red Docker `prod_backend` configurada
- Git instalado
- Al menos 4GB de RAM disponible
- Puerto 8088 libre

## 🚀 Configuración Rápida

### 1. Estructura de Archivos

Crea la siguiente estructura de directorios:

```
superset-docker/
├── docker-compose.yml
├── setup-superset.sh
├── quick-setup.sh              # Setup automático completo
├── docker/
│   ├── .env-non-dev
│   ├── .env-local
│   └── pythonpath_dev/
│       └── superset_config_docker.py
├── scripts/
│   ├── setup-superset-db.sh
│   ├── setup-network.sh
│   └── check-dependencies.sh
└── README.md
```

### 2. Configuración Inicial

**Opción A: Configuración Express (Recomendado)**
```bash
# Script todo-en-uno que maneja todo automáticamente
chmod +x quick-setup.sh
./quick-setup.sh
```

**Opción B: Configuración Manual**
```bash
# Asegurar que PostgreSQL y Redis externos están ejecutándose
cd ~/automation/shared/postgres
docker compose up -d

cd ~/automation/shared/redis
docker compose up -d

# Volver al directorio de Superset
cd ~/superset-docker

# Hacer ejecutable el script
chmod +x setup-superset.sh

# Ejecutar configuración automática
./setup-superset.sh start
```

### 3. Acceso a Superset

Una vez que todos los servicios estén corriendo:

- **URL**: http://localhost:8088
- **Usuario**: `admin`
- **Contraseña**: `admin`

## 🛠️ Comandos Disponibles

```bash
./setup-superset.sh start      # Iniciar todos los servicios
./setup-superset.sh stop       # Detener servicios
./setup-superset.sh restart    # Reiniciar servicios
./setup-superset.sh status     # Ver estado de servicios
./setup-superset.sh logs       # Ver logs en tiempo real
./setup-superset.sh deps       # Verificar dependencias externas
./setup-superset.sh update     # Actualizar imágenes
./setup-superset.sh cleanup    # Limpiar todo (¡cuidado!)
```

## 🏗️ Arquitectura del Sistema

### Servicios Incluidos

1. **superset** - Aplicación web principal (puerto 8088)
2. **superset-worker** - Procesador de tareas asíncronas
3. **superset-worker-beat** - Programador de tareas
4. **superset-init** - Inicialización de la base de datos

**Servicios Externos:**
- **postgres_prod** - PostgreSQL existente para metadatos (red prod_backend)
- **redis_prod** - Redis existente para cache y mensajería (red prod_backend)

### Volúmenes Persistentes

- `superset_home` - Configuraciones y logs de Superset
- `postgres_data` - Datos PostgreSQL (externo, gestionado separadamente)
- `redis_data` - Datos Redis (externo, gestionado separadamente)

### Arquitectura Resultante

```
┌─────────────────┐    ┌─────────────────┐
│   Superset Web  │    │ Superset Worker │
│   (puerto 8088) │    │   (async jobs)  │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
    ┌────────────────┼────────────────┐
    │           prod_backend         │ (red Docker)
    │                                │
    ├─ postgres_prod (existente)     │
    ├─ redis_prod (existente)        │
    └────────────────────────────────┘
```

## ⚙️ Configuración Personalizada

### Variables de Entorno

Edita `docker/.env-local` para personalizar:

```bash
# Clave secreta (genera una nueva con: openssl rand -base64 42)
SUPERSET_SECRET_KEY=tu-clave-secreta-aqui

# Datos de ejemplo (yes/no)
SUPERSET_LOAD_EXAMPLES=yes

# Puerto de Superset
SUPERSET_PORT=8088

# Clave API de Mapbox (opcional)
MAPBOX_API_KEY=tu-api-key
```

### **Configuración Actualizada**

**PostgreSQL (Externo):**
- **Host**: `postgres_prod` (nombre del contenedor)
- **Puerto**: `5432`
- **Base de datos**: `superset` (nueva, se crea automáticamente)
- **Usuario**: `postgres`
- **Contraseña**: `a8Nci+MpaOcFYzSa`

**Redis (Externo):**
- **Host**: `redis_prod` (nombre del contenedor)
- **Puerto**: `6379`
- **Contraseña**: `CQhgg6uELsQQwUXA`
- **Base de datos**: `0` (Celery), `1` (Cache)

### Configuración de Superset

Edita `docker/pythonpath_dev/superset_config_docker.py` para:

- Configurar autenticación OAuth/LDAP
- Ajustar límites de consultas
- Personalizar cache y celery
- Configurar alertas y reportes
- Añadir drivers de base de datos personalizados

## 🔧 Configuraciones Avanzadas

### Conectar Bases de Datos Externas

**Para bases de datos en contenedores Docker (misma red):**
```python
# En superset_config_docker.py o en la interfaz web
postgresql://user:pass@nombre_contenedor:5432/database
mysql://user:pass@mysql_container:3306/database
```

**Para bases de datos en el host (fuera de Docker):**
```python
# Linux: usar IP del bridge Docker
postgresql://user:pass@172.18.0.1:5432/database

# macOS/Windows: usar host especial
postgresql://user:pass@host.docker.internal:5432/database
```

**Para bases de datos remotas:**
```python
# Conexión directa por IP/dominio
postgresql://user:pass@192.168.1.100:5432/database
mysql://user:pass@database.empresa.com:3306/database
```

### Feature Flags

Habilita funcionalidades experimentales:

```python
FEATURE_FLAGS = {
    "THUMBNAILS": True,
    "ALERT_REPORTS": True,
    "DASHBOARD_RBAC": True,
    "ENABLE_TEMPLATE_PROCESSING": True,
    "SSH_TUNNELING": True,
}
```

### Autenticación OAUTH2

```python
from flask_appbuilder.security.manager import AUTH_OAUTH

AUTH_TYPE = AUTH_OAUTH
OAUTH_PROVIDERS = [
    {
        'name': 'google',
        'token_key': 'access_token',
        'icon': 'fa-google',
        'remote_app': {
            'client_id': 'tu-client-id',
            'client_secret': 'tu-client-secret',
            # ... más configuración
        }
    }
]
```

## 📊 Monitoreo y Mantenimiento

### Ver Logs

```bash
# Logs de todos los servicios
docker compose logs -f

# Logs específicos
docker compose logs -f superset
docker compose logs -f superset-worker
```

### Backup de Base de Datos

```bash
# Crear backup
docker compose exec postgres_prod pg_dump -U postgres superset > backup_$(date +%Y%m%d).sql

# Restaurar backup
docker compose exec -T postgres_prod psql -U postgres superset < backup_20241220.sql
```

### Actualización de Superset

```bash
# Método automático
./setup-superset.sh update

# Método manual
docker compose down
docker compose pull
docker compose up -d
```

## 🚨 Troubleshooting

### Problemas Comunes

1. **Puerto 8088 ocupado**
   ```bash
   # Cambiar puerto en docker/.env-local
   SUPERSET_PORT=8089
   ```

2. **Memoria insuficiente**
   ```bash
   # Reducir workers en docker-compose.yml
   # Deshabilitar ejemplos
   SUPERSET_LOAD_EXAMPLES=no
   ```

3. **Error de permisos**
   ```bash
   # Limpiar volúmenes
   ./setup-superset.sh cleanup
   ```

4. **Servicios externos no disponibles**
   ```bash
   # Verificar estado
   ./setup-superset.sh deps
   
   # Iniciar PostgreSQL
   cd ~/automation/shared/postgres && docker compose up -d
   
   # Iniciar Redis
   cd ~/automation/shared/redis && docker compose up -d
   ```

5. **Problemas de red Docker**
   ```bash
   # Verificar y reparar red
   docker network create prod_backend
   docker network connect prod_backend postgres_prod
   docker network connect prod_backend redis_prod
   ```

### Logs Útiles

```bash
# Estado de servicios
docker compose ps

# Uso de recursos
docker stats

# Información de volúmenes
docker volume ls
docker volume inspect superset_home
```

## 🔒 Consideraciones de Seguridad

### Para Desarrollo

- ✅ Contraseñas por defecto están bien
- ✅ HTTP está bien para desarrollo local
- ✅ Debug habilitado es útil

### Para Producción

- ❌ **NO usar este setup en producción**
- ✅ Usar Kubernetes o servidor gestionado
- ✅ Configurar HTTPS/SSL
- ✅ Usar secretos externos
- ✅ Configurar backup automático
- ✅ Habilitar autenticación robusta

## 📚 Referencias

- [Documentación oficial de Superset](https://superset.apache.org/)
- [Docker Compose de Superset](https://superset.apache.org/docs/installation/docker-compose)
- [Configuración de Superset](https://superset.apache.org/docs/configuration/configuring-superset)
- [Feature Flags](https://github.com/apache/superset/blob/master/RESOURCES/FEATURE_FLAGS.md)

## 💡 Tips Adicionales

### Desarrollo Frontend

Si planeas modificar el frontend de Superset:

```bash
# Deshabilitar build en Docker para mejor performance
export BUILD_SUPERSET_FRONTEND_IN_DOCKER=false

# Ejecutar npm localmente
cd superset-frontend/
npm install
npm run dev
```

### Conexión a Bases de Datos Locales

Para PostgreSQL/MySQL en tu host:
- **macOS**: usar `host.docker.internal`
- **Linux**: usar `172.18.0.1` o encontrar IP con `docker network inspect bridge`

### Performance

```python
# En superset_config_docker.py para mejor performance
SQLLAB_TIMEOUT = 300
SUPERSET_WEBSERVER_TIMEOUT = 300
ROW_LIMIT = 10000
```

### **Ventajas de esta Configuración**

🎯 **Reutilización completa de infraestructura** - Usa PostgreSQL y Redis existentes  
🔒 **Seguridad consistente** - Mismas credenciales y red para todos los servicios  
📈 **Máximo rendimiento** - Mínimo uso de recursos, sin duplicación  
🛠️ **Mantenimiento simplificado** - Una sola instancia de cada servicio  
🔄 **Integración total** - Ecosistema de contenedores unificado  
⚡ **Setup en un comando** - Script de configuración express automatizado  

---

## ⚠️ Nota Importante

Esta configuración está optimizada para **desarrollo/testing** usando tu infraestructura PostgreSQL y Redis existente. Para **producción**, considera:

- Usar un servicio gestionado como Amazon RDS, Google Cloud SQL
- Implementar backup automático de metadatos
- Configurar SSL/TLS en todas las conexiones
- Usar autenticación OAUTH/LDAP empresarial
- Monitoreo y alertas con Prometheus/Grafana
- Load balancer y múltiples instancias de Superset

La ventaja de esta configuración es que puedes **escalar gradualmente** usando la misma base de conocimiento y configuración.