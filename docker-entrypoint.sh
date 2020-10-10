#!/bin/bash

# prepare GitList config.ini for sed matching
CONFIG=/var/www/gitlist/config.ini
cp /var/www/gitlist/config.ini-example ${CONFIG}
sed -i '/WINDOWS USERS/,+3d' ${CONFIG} 
sed -i "s#repositories\[\] = '/home/git/repositories/'##g" ${CONFIG}

# configuration based on env vars
if [ "${TZ}" ]; then sed -i "s#; timezone = UTC#timezone = '${TZ}'#g" ${CONFIG}; fi
if [ "${DATEFORMAT}" ]; then sed -i "s#; format = 'd/m/Y H:i:s'#format = '${DATEFORMAT}'#g" ${CONFIG}; fi
if [ "${THEME}" ]; then sed -i "s#theme = \"default\"#theme = \"${THEME}\"#g" ${CONFIG}; fi
if [ "${PASSWORD}" ]; then
  echo "* Configuring admin password"
  htpasswd -b -c /var/www/.htpasswd admin ${PASSWORD}
  sed -i 's@#   auth_basic "Restricted";@   auth_basic "Restricted";@g' /etc/nginx.conf
  sed -i 's@#   auth_basic_user_file .htpasswd;@   auth_basic_user_file /var/www/.htpasswd;@g' /etc/nginx.conf
else
  echo "* No admin password specified"
fi

# tweak UI to prevent influx of bug reports to GitList GitHub repo from this docker
for THEME in default bootstrap3; do
  sed -i -r '\#/gitlist/(issues|wiki)#d' /var/www/gitlist/themes/${THEME}/twig/navigation.twig
done

# add robots.txt file
cat << EOF > /var/www/gitlist/robots.txt
User-agent: *
Disallow: /
EOF

# test for Unraid flash drive
if [ -d "/repos/boot/.git" ]; then
  echo "* Unraid flash drive found"
elif [ -d "/repos/boot/" ]; then
  echo "* Unraid flash drive found, but not configured with git"
else
  echo "* Unraid flash drive not found"
fi

# loop through /repos*, if they exist and contain a .git folder, add to list of repositories
HASREPO=0
NEEDROOT=0
for REPODIR in /repos /repos2 /repos3 /repos4 /repos5; do
if [ -d ${REPODIR} ]; then
  GITREPOS=$(find ${REPODIR} -maxdepth 2 -type d | grep '^/.*/.*/.git$')
  if [ "${GITREPOS}" ]; then
    # gitrepos exist in this repodir, add repodir to the GitList config
    HASREPO=1
    sed -i "s#Path to your repositories#\nrepositories[] = '${REPODIR}/' ; Path to your repositories#g" ${CONFIG}; 
    for GITREPO in ${GITREPOS}; do
      # if this gitrepo is not world readable and executable, set flag to run GitList as root
      PERM=`stat -c %a ${GITREPO} | cut -c3`
      if [[ ${PERM} -ne 5 && ${PERM} -ne 7 ]]; then
        NEEDROOT=1
        echo "* Found ${GITREPO}, needs root to access"
      else
        echo "* Found ${GITREPO}"
      fi
    done
  fi
fi
done

# if no repos exist, make a dummy repo so GitList won't crash
if [ "${HASREPO}" = "0" ]; then
  REPODIR="/repos"
  echo "* No repositories found, creating ${REPODIR}/sentinel/ to prevent GitList from crashing"
  mkdir -p "${REPODIR}/sentinel"; cd "${REPODIR}/sentinel"; git --bare init .
  echo "WARNING: GitList Docker configured incorrectly, you need to pass in a folder containing your git repositories" > "${REPODIR}/sentinel/description"
  sed -i "s#Path to your repositories#\nrepositories[] = '${REPODIR}/' ; Path to your repositories#g" ${CONFIG}; 
fi

# If any gitrepos need root to access, set php and nginx to run as root so can read the files
if [ "${NEEDROOT}" = "1" ]; then
  echo "* Configuring GitList to run as root"
  sed -i 's/www-data/root/g' /etc/nginx.conf
  sed -i 's/www-data/root/g' /etc/php5/fpm/pool.d/www.conf
  sed -i 's#/etc/php5/fpm/php-fpm.conf#/etc/php5/fpm/php-fpm.conf --allow-to-run-as-root#g' /etc/init.d/php5-fpm
else
  echo "* Configuring GitList to run as www-data"
fi

# display relevant config
echo "* Config settings"
grep -E "^user" /etc/nginx.conf
grep -E "^(repositories\[\]|timezone|format|theme) =" ${CONFIG}

# start php and nginx
service php5-fpm restart
nginx -c /etc/nginx.conf
