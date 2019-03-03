#!/bin/bash
cp /var/www/gitlist/config.ini-example /var/www/gitlist/config.ini
sed -i 's#/home/git/repositories/#/repos/#g' /var/www/gitlist/config.ini
if [ "$TZ" ]; then sed -i "s#; timezone = UTC#timezone = '$TZ'#g" /var/www/gitlist/config.ini; fi
if [ "$DATEFORMAT" ]; then sed -i "s#; format = 'd/m/Y H:i:s'#format = '$DATEFORMAT'#g" /var/www/gitlist/config.ini; fi
if [ "$THEME" ]; then sed -i "s#theme = \"default\"#theme = \"$THEME\"#g" /var/www/gitlist/config.ini; fi
service php5-fpm restart; nginx -c /etc/nginx.conf