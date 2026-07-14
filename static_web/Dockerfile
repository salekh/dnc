FROM nginx:alpine-slim

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Add custom nginx config optimized for static serving
COPY nginx.conf /etc/nginx/conf.d/

# Copy static files
COPY . /usr/share/nginx/html/

# Remove non-web files from the image
RUN rm -f /usr/share/nginx/html/Dockerfile /usr/share/nginx/html/nginx.conf /usr/share/nginx/html/.dockerignore

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
