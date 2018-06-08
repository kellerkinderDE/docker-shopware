#!/bin/bash

SHOPWARE_INSTALLED=1

if [ ! -e /var/www/html/shopware.php ]; then
    SHOPWARE_INSTALLED=0
    curl http://releases.s3.shopware.com.s3.amazonaws.com/install_$SHOPWARE_VERSION.zip -o /tmp/shopware.zip
    mkdir /tmp/shopware
    rm -f /var/www/html/index.html && unzip -d /tmp/shopware /tmp/shopware.zip || exit 1
    rsync --ignore-existing -r /tmp/shopware/ /var/www/html
fi

if [ $SHOPWARE_INSTALLED -eq 0 ]; then
    export SHOP_LOCALE=${LOCALE-"de_DE"}
    export SHOPNAME=${NAME-"Test Shop"}

    php /var/www/html/recovery/install/index.php --db-host="$DATABASE_HOST" --db-user="$DATABASE_USER" --db-password="$DATABASE_PASSWORD" --db-name="$DATABASE_DB" --admin-username="demo" --admin-password="demo" --admin-locale="$SHOP_LOCALE" --admin-name="Demo-Admin" --admin-email="$ADMIN_EMAIL" --shop-locale="$SHOP_LOCALE" --shop-host="$SERVERNAME" --shop-currency="EUR" --shop-name="$SHOPNAME"

    php /var/www/html/bin/console sw:firstrunwizard:disable
fi

for i in config.php \
    var/log/ \
    var/cache/ \
    web/cache/ \
    files/documents/ \
    files/downloads/ \
    recovery/ \
    custom/plugins \
    engine/Shopware/Plugins/Community/ \
    engine/Shopware/Plugins/Community/Frontend \
    engine/Shopware/Plugins/Community/Core \
    engine/Shopware/Plugins/Community/Backend \
    engine/Shopware/Plugins/Default/ \
    engine/Shopware/Plugins/Default/Frontend \
    engine/Shopware/Plugins/Default/Core \
    engine/Shopware/Plugins/Default/Backend \
    themes/Frontend \
    media/archive/ \
    media/image/ \
    media/image/thumbnail/ \
    media/music/ \
    media/pdf/ \
    media/unknown/ \
    media/video/ \
    media/temp/ \
    recovery/install/data; do
        chmod 777 /var/www/html/$i
done

exec apache2-foreground