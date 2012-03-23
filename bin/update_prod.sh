#!/usr/bin/env bash
#
# Author: Philipp A. Mohrenweiser
# Contact: mailto:phiamo@googlemail.com
# Version: $id$

set +e
scriptPath=$(readlink -f "${0%/*}")

. $scriptPath/envvars

APACHE_RUN_USER="${APACHE_RUN_USER-www-data}"
APACHE_RUN_GROUP="${APACHE_RUN_GROUP-www-data}"
dirs="${dirs-app/cache app/logs}"
echo "RUNNING CHMOD AS $APACHE_RUN_USER:$APACHE_RUN_GROUP on $dirs"
git pull
app/console --env=prod cache:clear --no-debug
echo -n "restarting your webserver:"
if [ -e "/etc/init.d/apache2" ]; then
    sudo /etc/init.d/apache2 restart
elif [ -e "/etc/init.d/nginx" ]; then
    sudo /etc/init.d/nginx restart
    sudo /etc/init.d/php5-fpm restart
elif [ -e "/etc/init.d/lighttpd" ]; then
    sudo /etc/init.d/lighttpd restart
else
    echo "NOT WEBSERVER FOUND!"
fi

app/console --env=prod assets:install web
app/console --env=prod assetic:dump --no-debug
sudo chown $APACHE_RUN_USER.$APACHE_RUN_GROUP -R $dirs
sudo chmod 765 -R $dirs
