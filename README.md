# Sosko's AIO PHP Recipe
The recipe provides a very simple yet extensible AIO container that allows for HTTP-ready containerised PHP.

## Introduction
Try it out. `docker run -p 8080:8080 markomitranic/sosko-aio-php` Will spawn a little "server" on port 8080 that you can visit.

Generally, it's not meant to be used by itself, but to be extended by other (your) containers. Also here is an example of how we use it.

```
FROM markomitranic/sosko-aio-php:7.3 AS base

# Install some additional packages:
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    nano \
    vim \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Activate additional PHP extensions
RUN yes | pecl install mongodb \
&& docker-php-ext-enable mongodb \
&& rm -rf /tmp/pear

# Customise or override some of the predefined conf files
COPY config/php.ini /usr/local/etc/php/conf.d/z-custom.ini
COPY config/default.conf /etc/nginx/conf.d/default.conf
```

## XDebug or Blackfire?
Just follow the installation steps of those particular services.
Lets see an XDEBUG example:
```
FROM base AS dev

ARG XDEBUG_ACTIVE=0
ARG XDEBUG_HOST_IP=host.docker.internal

# Install XDebug
RUN if [ "$XDEBUG_ACTIVE" -eq 1 ] ; then \
        yes | pecl install xdebug \
        && rm -rf /tmp/pear \
        && docker-php-ext-enable xdebug \
        && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.remote_host=$XDEBUG_HOST_IP" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    ; fi
```

# One container, one service?
This needs a long talk. Might be written later on.

FPM running by itself is not HTTP-ready and cannot be used by other services apart from apache or nginx. Also, both of these have mixed responsibilities and need access to same files at same locations. Spooky action at a distance i'd say.

Essentially, while you should always strive towards having a "clear" PHP app that does not deal with any static (non php) files at all. (and thus fully decouple the containers) The usual suspects such as WP or IPS do not like that. In these specific cases, this is the best you've got. 

For now.