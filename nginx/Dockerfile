FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

# Update pkgs
RUN apk update >/dev/null

# Copy settings and dependencies
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/errors.conf /etc/nginx/conf.d/errors.conf
COPY static /app
COPY ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
