FROM nginx:alpine

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled Flutter web files into Nginx public folder
COPY build/web /usr/share/nginx/html

EXPOSE 8600

CMD ["nginx", "-g", "daemon off;"]