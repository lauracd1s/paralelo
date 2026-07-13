FROM nginx:alpine

# Copiar el HTML al directorio de nginx
COPY index.html /usr/share/nginx/html/index.html

# Configuración de nginx para SPA
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
    location /health { \
        return 200 "ok"; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
