FROM php:7.1-apache

MAINTAINER Uwe Kleinmann <u.kleinmann@kellerkinder.de>

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    git \
    libfreetype6-dev \
    libmcrypt-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libssl-dev \
    libxml2-dev \
    mysql-client \
    rsync \
    zlib1g-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    && docker-php-ext-install -j$(nproc) intl mcrypt pdo_mysql soap opcache zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

VOLUME ["/var/www/html"]

COPY files/entrypoint.sh /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]