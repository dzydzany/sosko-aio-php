FROM php:7.3-fpm

USER root
# Install packages:
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
	nginx \
	supervisor \
    wget \
    mariadb-client \
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    libwebp-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxpm-dev \
    libfreetype6-dev \
    libzip-dev \
    libmagickwand-dev libmagickcore-dev \
    libzstd-dev \
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev \
    unzip \
    git \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Activate PHP extensions
RUN docker-php-ext-configure gd \
&& docker-php-ext-install \
    gd \
    zip \
    mysqli \
    pdo_mysql \
    exif \
    opcache \
    intl \
&& yes | pecl install imagick igbinary redis \
&& docker-php-ext-enable imagick igbinary redis opcache \
&& rm -rf /tmp/pear

# Configure nginx
RUN rm /etc/nginx/sites-enabled/default
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/default.conf /etc/nginx/conf.d/default.conf
# Configure PHP-FPM
COPY config/php/fpm-pool.conf /usr/local/etc/php-fpm.d/www.conf
COPY config/php/php.ini /usr/local/etc/php/conf.d/custom.ini
ENV LOG_CHANNEL=stderr
# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config/stop-supervisord.sh /sbin/stop-supervisord.sh

# Expose the port nginx is reachable on
EXPOSE 8080
# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
# Let supervisord start nginx & php-fpm
COPY config/entrypoint.sh /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
# Copy dummy welcome page
COPY ./public/ /app/src/
WORKDIR /app/src/
