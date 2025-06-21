# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# This file is included in the final Docker image and SHOULD be overridden when
# deploying the image to prod. Settings configured here are intended for use in local
# development environments. Also note that superset_config_docker.py is imported
# as a final step as a means to override "defaults" configured in superset_config.py

import logging
import os
from datetime import timedelta
from typing import Optional

from cachelib.file import FileSystemCache
from celery.schedules import crontab

logger = logging.getLogger()

def get_env_variable(var_name: str, default: Optional[str] = None) -> str:
    """Get the environment variable or raise exception."""
    try:
        return os.environ[var_name]
    except KeyError:
        if default is not None:
            return default
        else:
            error_msg = f"The environment variable {var_name} was missing, abort..."
            raise EnvironmentError(error_msg)

# The SQLAlchemy connection string.
SQLALCHEMY_DATABASE_URI = f"postgresql://{get_env_variable('DATABASE_USER')}:" \
                          f"{get_env_variable('DATABASE_PASSWORD')}@" \
                          f"{get_env_variable('DATABASE_HOST')}:" \
                          f"{get_env_variable('DATABASE_PORT')}/" \
                          f"{get_env_variable('DATABASE_DB')}"

# Redis
REDIS_HOST = get_env_variable("REDIS_HOST")
REDIS_PORT = get_env_variable("REDIS_PORT")
REDIS_PASSWORD = get_env_variable("REDIS_PASSWORD")
REDIS_CELERY_DB = 0
REDIS_RESULTS_DB = 1

RESULTS_BACKEND = FileSystemCache("/app/superset_home/sqllab")

# Celery configuration
CELERY_CONFIG = {
    "broker_url": f"redis://:{REDIS_PASSWORD}@{REDIS_HOST}:{REDIS_PORT}/{REDIS_CELERY_DB}",
    "imports": [
        "superset.sql_lab",
        "superset.tasks.scheduler",
        "superset.tasks.thumbnails",
        "superset.tasks.cache",
    ],
    "result_backend": f"redis://:{REDIS_PASSWORD}@{REDIS_HOST}:{REDIS_PORT}/{REDIS_RESULTS_DB}",
    "worker_prefetch_multiplier": 1,
    "task_acks_late": False,
    "task_annotations": {
        "sql_lab.get_sql_results": {
            "rate_limit": "100/s",
        },
    },
}

# Cache configuration
CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 300,
    "CACHE_KEY_PREFIX": "superset_",
    "CACHE_REDIS_HOST": REDIS_HOST,
    "CACHE_REDIS_PORT": REDIS_PORT,
    "CACHE_REDIS_PASSWORD": REDIS_PASSWORD,
    "CACHE_REDIS_DB": 1,
}

# Data cache configuration
DATA_CACHE_CONFIG = CACHE_CONFIG

# Feature flags
FEATURE_FLAGS = {
    "THUMBNAILS": True,
    "ALERT_REPORTS": True,
    "DASHBOARD_RBAC": True,
    "ENABLE_TEMPLATE_PROCESSING": True,
}

# Alert and reporting configuration
ALERT_REPORTS_NOTIFICATION_DRY_RUN = True
WEBDRIVER_BASEURL = "http://superset:8088/"
# The base URL for the email report hyperlinks.
WEBDRIVER_BASEURL_USER_FRIENDLY = WEBDRIVER_BASEURL

SQLLAB_CTAS_NO_LIMIT = True

# Security configuration
WTF_CSRF_ENABLED = True
WTF_CSRF_TIME_LIMIT = 60 * 60 * 24 * 365

# Superset specific configuration
ROW_LIMIT = 5000
SUPERSET_WEBSERVER_PORT = 8088

# Flask session configuration
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SECURE = False  # Set to True in production with HTTPS
SESSION_COOKIE_SAMESITE = "Lax"

# Enable Mapbox visualizations if API key is provided
MAPBOX_API_KEY = get_env_variable("MAPBOX_API_KEY", "")

# Optional: Custom branding
# APP_NAME = "Mi Dashboard"
# APP_ICON = "/static/assets/images/superset-logo-horiz.png"

# Optional: Email configuration for alerts
# SMTP_HOST = "localhost"
# SMTP_STARTTLS = True
# SMTP_SSL = False
# SMTP_USER = "superset"
# SMTP_PORT = 587
# SMTP_PASSWORD = "superset"
# SMTP_MAIL_FROM = "superset@superset.com"

# Logging configuration
ENABLE_TIME_ROTATE = True
TIME_ROTATE_LOG_LEVEL = "DEBUG"
FILENAME = os.path.join(DATA_DIR, "superset.log")

# Optional: Custom authentication
# Uncomment and configure as needed
# from flask_appbuilder.security.manager import AUTH_OAUTH
# AUTH_TYPE = AUTH_OAUTH

# Optional: Custom database drivers
# Uncomment the databases you want to support
# pip install PyMySQL for MySQL
# pip install cx_Oracle for Oracle
# pip install pyodbc for SQL Server

# Custom CSS
# CUSTOM_CSS = """
# .navbar-brand {
#     color: #FF6B6B !important;
# }
# """