#!/bin/bash
cp /var/www/gitlist/config.ini-example /var/www/gitlist/config.ini
# prepare config.ini for sed matching
sed -i '/WINDOWS USERS/,+3d' /var/www/gitlist/config.ini 
sed -i "s#repositories\[\] = '/home/git/repositories/'##g" /var/www/gitlist/config.ini

# make a dummy repo
mkdir -p /repos/sentinel; cd /repos/sentinel; git --bare init .

# loop through /repos*, if they exist and contain a .git folder, add to list of repositories
for REPODIR in /repos /repos2 /repos3 /repos4 /repos5; do
if [ -d ${REPODIR} ] && [ "$(find ${REPODIR} -maxdepth 2 -type d | grep '^/.*/.*/.git$')" ]; then
  sed -i "s#Path to your repositories#\nrepositories[] = '${REPODIR}/' ; Path to your repositories#g" /var/www/gitlist/config.ini; 
fi
done
# additional configuration based on env vars
if [ "${TZ}" ]; then sed -i "s#; timezone = UTC#timezone = '${TZ}'#g" /var/www/gitlist/config.ini; fi
if [ "${DATEFORMAT}" ]; then sed -i "s#; format = 'd/m/Y H:i:s'#format = '${DATEFORMAT}'#g" /var/www/gitlist/config.ini; fi
if [ "${THEME}" ]; then sed -i "s#theme = \"default\"#theme = \"${THEME}\"#g" /var/www/gitlist/config.ini; fi
# display relevent config
grep -E "(repositories\[\]|timezone|format|theme) =" /var/www/gitlist/config.ini
# start nginx
service php5-fpm restart; nginx -c /etc/nginx.conf
