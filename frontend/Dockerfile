# frontend/Dockerfile
FROM nginx:alpine

# Use our Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY index.html /usr/share/nginx/html/index.html
COPY script.js  /usr/share/nginx/html/script.js

EXPOSE 80

