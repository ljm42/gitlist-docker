#!/bin/bash
cp /var/www/gitlist/config.ini-example /var/www/gitlist/config.ini
# prepare config.ini for sed matching
sed -i '/WINDOWS USERS/,+3d' /var/www/gitlist/config.ini 
sed -i "s#repositories\[\] = '/home/git/repositories/'##g" /var/www/gitlist/config.ini

# loop through /repos*, if they exist and contain a .git folder, add to list of repositories
REPO=0
for REPODIR in /repos /repos2 /repos3 /repos4 /repos5; do
if [ -d ${REPODIR} ] && [ "$(find ${REPODIR} -maxdepth 2 -type d | grep '^/.*/.*/.git$')" ]; then
  sed -i "s#Path to your repositories#\nrepositories[] = '${REPODIR}/' ; Path to your repositories#g" /var/www/gitlist/config.ini; 
  REPO=1
fi
done
# if no repos exist, make a dummy repo so gitlist won't crash
if [ "${REPO}" = "0" ]; then
  REPODIR="/repos"
  mkdir -p "${REPODIR}/sentinel"; cd "${REPODIR}/sentinel"; git --bare init .
  sed -i "s#Path to your repositories#\nrepositories[] = '${REPODIR}/' ; Path to your repositories#g" /var/www/gitlist/config.ini; 
fi

# additional configuration based on env vars
if [ "${TZ}" ]; then sed -i "s#; timezone = UTC#timezone = '${TZ}'#g" /var/www/gitlist/config.ini; fi
if [ "${DATEFORMAT}" ]; then sed -i "s#; format = 'd/m/Y H:i:s'#format = '${DATEFORMAT}'#g" /var/www/gitlist/config.ini; fi
if [ "${THEME}" ]; then sed -i "s#theme = \"default\"#theme = \"${THEME}\"#g" /var/www/gitlist/config.ini; fi

if [ -d /repos/boot ]; then
  PERM=`stat -c %a /repos/boot | cut -c3`
  if [[ $PERM -ne 5 && $PERM -ne 7 ]]; then
    # set php and nginx to run as root so can read the Unraid flash drive
    sed -i 's/www-data/root/g' /etc/nginx.conf
    sed -i 's/www-data/root/g' /etc/php5/fpm/pool.d/www.conf
    sed -i 's#/etc/php5/fpm/php-fpm.conf#/etc/php5/fpm/php-fpm.conf --allow-to-run-as-root#g' /etc/init.d/php5-fpm
  fi
fi

# display relevent config
grep -E "^user" /etc/nginx.conf
grep -E "(repositories\[\]|timezone|format|theme) =" /var/www/gitlist/config.ini

# start php and nginx
service php5-fpm restart
nginx -c /etc/nginx.conf

