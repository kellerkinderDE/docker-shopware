#!/bin/bash

SHOPWARE_INSTALLED=1

if [ ! -e /var/www/html/shopware.php ]; then
    SHOPWARE_INSTALLED=0
    curl http://releases.s3.shopware.com.s3.amazonaws.com/install_$SHOPWARE_VERSION.zip -s -S -o /tmp/shopware.zip
    mkdir /tmp/shopware
    rm -f /var/www/html/index.html && unzip -d /tmp/shopware /tmp/shopware.zip > /dev/null || exit 1
    rsync --ignore-existing -r /tmp/shopware/ /var/www/html >/dev/null
fi

export SHOP_LOCALE=${LOCALE-"de_DE"}
export SHOPNAME=${NAME-"Test Shop"}
if [ $SHOPWARE_INSTALLED -eq 0 ]; then
    /wait-for-it.sh $DATABASE_HOST:3306 -t 0

    php /var/www/html/recovery/install/index.php --db-host="$DATABASE_HOST" --db-user="$DATABASE_USER" --db-password="$DATABASE_PASSWORD" --db-name="$DATABASE_DB" --admin-username="demo" --admin-password="demo" --admin-locale="$SHOP_LOCALE" --admin-name="Demo-Admin" --admin-email="$ADMIN_EMAIL" --shop-locale="$SHOP_LOCALE" --shop-host="$SERVERNAME" --shop-currency="EUR" --shop-name="$SHOPNAME" -q

    php /var/www/html/bin/console sw:firstrunwizard:disable
fi

export INSTALL_DEMO=${USE_DEMO-"0"}
if [ $INSTALL_DEMO -ne "0" ]; then
    php /var/www/html/bin/console sw:store:download SwagDemoDataDE
    php /var/www/html/bin/console sw:plugin:refresh
    php /var/www/html/bin/console sw:plugin:install --activate SwagDemoDataDE
fi

if [[ -n "${CLONE_URL}" ]]; then
    # it's a review app

    if [[ -n "${PLUGIN_NAME}" ]]; then
        # it's a plugin
        git clone "${CLONE_URL}" /var/www/html/custom/plugins/${PLUGIN_NAME}
    elif [[ -n "${PROJECT_ROOT}" ]]; then
        # it's a shop
        git clone "${CLONE_URL}" /tmp/project
        rsync -r "/tmp/project/${PROJECT_ROOT}/" /var/www/html >/dev/null
        rm -rf /tmp/project
    fi
fi

find /var/www/html/custom/plugins -type f -name kellerkinder-plugin.json -exec php /kellerkinder-plugin.php {} \;

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

chown -R www-data:www-data /var/www/html

exec apache2-foreground
