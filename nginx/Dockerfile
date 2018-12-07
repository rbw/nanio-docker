FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

# Install environment
RUN apk update >/dev/null

# Copy settings and dependencies
COPY nginx.conf /etc/nginx/nginx.conf
COPY static /app
COPY ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
