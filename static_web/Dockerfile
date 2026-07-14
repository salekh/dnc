FROM nginx:alpine-slim

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Add custom nginx config optimized for static serving
COPY nginx.conf /etc/nginx/conf.d/

# Copy static files and ensure all assets are readable by Nginx worker
COPY . /usr/share/nginx/html/
RUN chmod -R a+rX /usr/share/nginx/html/ && \
    rm -f /usr/share/nginx/html/Dockerfile /usr/share/nginx/html/nginx.conf /usr/share/nginx/html/.dockerignore

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
