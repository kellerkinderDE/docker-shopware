FROM php:7.1-apache

MAINTAINER Uwe Kleinmann <u.kleinmann@kellerkinder.de>

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    git \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    mysql-client \
    rsync \
    zlib1g-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    && docker-php-ext-install -j$(nproc) intl mcrypt pdo_mysql soap opcache zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY files/apache-vhost.conf /etc/apache2/sites-enabled/000-default.conf
COPY files/php-config.ini /usr/local/etc/php/conf.d/php-config.ini
COPY files/php-timezone.ini /usr/local/etc/php/conf.d/php-timezone.ini

RUN a2enmod rewrite

VOLUME ["/var/www/html"]

COPY files/entrypoint.sh /entrypoint.sh
COPY files/wait-for-it/wait-for-it.sh /wait-for-it.sh
COPY files/kellerkinder-plugin.php /kellerkinder-plugin.php

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
