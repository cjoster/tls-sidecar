FROM nginx:stable-alpine3.17-slim

COPY nginx.conf /etc/nginx/
COPY docker-entrypoint.d/ docker-entrypoint.d/

CMD ["nginx", "-g", "daemon off;", "-c", "/tmp/nginx.conf"]
