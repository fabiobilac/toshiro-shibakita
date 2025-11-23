# Multi-stage build para aplicação PHP
FROM php:8.2-apache as base

# Instalar extensões necessárias
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Habilitar mod_rewrite do Apache
RUN a2enmod rewrite

# Configurar diretório de trabalho
WORKDIR /var/www/html

# Copiar aplicação
COPY index.php /var/www/html/

# Ajustar permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expor porta
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Stage de produção
FROM base as production

# Configurações de segurança do PHP
RUN { \
    echo 'display_errors = Off'; \
    echo 'log_errors = On'; \
    echo 'error_log = /var/log/apache2/php_errors.log'; \
    echo 'expose_php = Off'; \
    } > /usr/local/etc/php/conf.d/security.ini

# Stage de desenvolvimento
FROM base as development

RUN { \
    echo 'display_errors = On'; \
    echo 'error_reporting = E_ALL'; \
    } > /usr/local/etc/php/conf.d/development.ini

# Usar stage de produção por padrão
FROM production
