FROM nginx

EXPOSE 80

COPY src/ /usr/share/nginx/html/

ENTRYPOINT ["/docker-entrypoint.sh", "nginx", "-g", "daemon off;" ]
