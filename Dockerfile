FROM wangxian/alpine-php:latest
MAINTAINER WangXian <xian366@126.com>

ENV NGINX_VERSION nginx-1.8.0

RUN apk --update add openssl-dev pcre-dev zlib-dev wget build-base
RUN mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxvf ${NGINX_VERSION}.tar.gz && \
    wget http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz && \
    tar -zxvf ngx_cache_purge-2.3.tar.gz && \
    mkdir -p /var/nginx/cache/one
RUN cd /tmp/src/${NGINX_VERSION} && \
    ./configure \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --prefix=/usr/local/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx \
        --with-http_sub_module && \
    make && \
    make install && \
    apk del build-base && \
    rm -rf /tmp/src && \
    rm -rf /var/cache/apk/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /app
VOLUME /app

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]