# Dockerfile para Nginx Load Balancer
FROM nginx:alpine

# Remover configuração padrão
RUN rm /etc/nginx/conf.d/default.conf

# Copiar configuração customizada
COPY nginx.conf /etc/nginx/nginx.conf

# Expor porta
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Comando padrão
CMD ["nginx", "-g", "daemon off;"]
