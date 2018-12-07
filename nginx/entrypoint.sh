#!/usr/bin/env sh

NGINX_FILE="/etc/nginx/nginx.conf"
NANIO_FILE="/etc/nginx/conf.d/nanio.conf"
RATE_FILE="/etc/nginx/conf.d/rf.conf"

USE_NGINX_WORKER_PROCESSES=${WORKER_PROCESSES:-1}
REQUESTS_PER_SECOND_MAX=${RPS_MAX:-2}
USE_LISTEN_PORT=${LISTEN_PORT:-80}
NANIO_CORE_URL=${NANIO_URL:-http://127.0.0.1:8080}

sed -i "/worker_processes\s/c\worker_processes ${USE_NGINX_WORKER_PROCESSES};" ${NGINX_FILE}
echo "limit_req_zone \$binary_remote_addr zone=req_limit:10m rate=${REQUESTS_PER_SECOND_MAX}r/s;" > ${RATE_FILE}

echo "server {
        root /app;
        index index.html;
" > ${NANIO_FILE}

if [[ "${USE_SSL}" == 1 && -f /certs/cert.crt && -f /certs/cert.key ]] ; then
    echo "listen ${USE_LISTEN_PORT} ssl;
          ssl_certificate        /certs/cert.crt;
          ssl_certificate_key    /certs/cert.key;
    " >> ${NANIO_FILE}
else
    echo "listen ${USE_LISTEN_PORT};" >> ${NANIO_FILE}
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
        proxy_pass ${NANIO_CORE_URL};
    }
    location /node-rpc {
        limit_req zone=req_limit burst=5 nodelay;
        proxy_pass_header Server;
        proxy_set_header Host \$http_host;
        proxy_redirect off;
        proxy_pass ${NANIO_CORE_URL};
    }
}" >> ${NANIO_FILE}

exec "$@"
