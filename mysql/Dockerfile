# Dockerfile para MySQL customizado
FROM mysql:8.0

# Copiar script de inicialização
COPY init.sql /docker-entrypoint-initdb.d/

# Configurações customizadas do MySQL
RUN echo '[mysqld]\n\
max_connections=200\n\
character-set-server=utf8mb4\n\
collation-server=utf8mb4_unicode_ci\n\
default-time-zone="-03:00"\n\
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION\n\
\n\
[client]\n\
default-character-set=utf8mb4' > /etc/mysql/conf.d/custom.cnf

# Expor porta
EXPOSE 3306

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD} || exit 1
