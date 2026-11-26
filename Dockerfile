FROM nginx:1.27-alpine
RUN rm -rf /usr/share/nginx/html/*
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
HEALTHCHECK CMD wget -q --spider http://localhost/ || exit 1
