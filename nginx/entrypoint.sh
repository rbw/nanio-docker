#!/usr/bin/env bash

NGINX_FILE="/etc/nginx/nginx.conf"
NANIO_FILE="/etc/nginx/conf.d/nanio.conf"
RATE_FILE="/etc/nginx/conf.d/rf.conf"

WORKER_PROCESSES=${NGINX_WORKERS:-1}
RPS_MAX=${NGINX_RPS:-2}
NANIO_CORE=${NANIO_ADDRESS:-127.0.0.1:8080}

sed -i "/worker_processes\s/c\worker_processes ${WORKER_PROCESSES};" ${NGINX_FILE}
echo "limit_req_zone \$binary_remote_addr zone=req_limit:10m rate=${RPS_MAX}r/s;" > ${RATE_FILE}

if [[ "${USE_SSL}" == 1 && -f /certs/cert.crt && -f /certs/cert.key ]] ; then
    echo "server {
          listen 80;
          return 301 https://\$server_name\$request_uri;
      }" >> ${NANIO_FILE}
fi

echo "server {
        root /app;
        index index.html;
" >> ${NANIO_FILE}

if [[ "${USE_SSL}" == 1 && -f /certs/cert.crt && -f /certs/cert.key ]] ; then
    echo "listen 443 ssl;
          ssl_certificate        /certs/cert.crt;
          ssl_certificate_key    /certs/cert.key;
    " >> ${NANIO_FILE}
else
    echo "listen 80;" >> ${NANIO_FILE}
fi

echo "
    location / {
        try_files \$uri \$uri/ =404;
    }
    location /api {
        limit_req zone=req_limit nodelay;
        proxy_pass_header Server;
        proxy_set_header Host \$http_host;
        proxy_redirect off;
        proxy_pass http://${NANIO_CORE};
    }
    location /node-rpc {
        limit_req zone=req_limit burst=5 nodelay;
        proxy_pass_header Server;
        proxy_set_header Host \$http_host;
        proxy_redirect off;
        proxy_pass http://${NANIO_CORE};
    }
}" >> ${NANIO_FILE}

exec "$@"
