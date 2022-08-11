FROM nginx:1.21.6-alpine

LABEL org.opencontainers.image.source="https://github.com/gabriel-brotas/backstage-charts"

WORKDIR /var/www/html

EXPOSE 3000

ENTRYPOINT ["nginx", "-g", "daemon off;"]



