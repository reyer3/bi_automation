# postgres.Dockerfile
FROM timescale/timescaledb-ha:pg17
USER root

# Instala locales y la extensión vector
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      locales \
      postgresql-17-pgvector \
 && sed -i 's/# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
 && locale-gen en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/*

# Fuerza initdb con el locale correcto
ENV POSTGRES_INITDB_ARGS="--locale=en_US.UTF-8 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8"

# Vuelve a postgres y copia tus scripts de arranque
USER postgres
COPY init/ /docker-entrypoint-initdb.d/