FROM nginx:1.21.6-alpine

LABEL org.opencontainers.image.source="https://github.com/gabriel-brotas/backstage-charts"

EXPOSE 3000

RUN echo "hey 2"

ENTRYPOINT ["nginx", "-g", "daemon off;"]



