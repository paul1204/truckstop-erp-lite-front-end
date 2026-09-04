FROM nginx:alpine

# Default backend URL for local docker-compose setup (zero configuration)
ENV BACKEND_URL=http://backend:9000
# Restrict envsubst to BACKEND_URL so Nginx runtime variables ($uri, $host, etc.) are preserved
ENV NGINX_ENVSUBST_FILTER=BACKEND_URL

# Copy custom Nginx configuration template for container startup envsubst processing
COPY nginx.conf /etc/nginx/templates/default.conf.template

# Copy compiled Flutter web files into Nginx public folder
COPY build/web /usr/share/nginx/html

EXPOSE 80 8600

CMD ["nginx", "-g", "daemon off;"]