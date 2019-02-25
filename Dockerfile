FROM ubuntu:14.04
RUN apt-get update
RUN apt-get -y install git nginx-full php5-fpm curl
ADD https://github.com/klaussilveira/gitlist/releases/download/1.0.1/gitlist-1.0.1.tar.gz /var/www/
RUN cd /var/www; tar -zxvf gitlist-1.0.1.tar.gz
RUN chmod -R 777 /var/www/gitlist
RUN cd /var/www/gitlist/; mkdir cache; chmod 777 cache
RUN cp /var/www/gitlist/config.ini-example /var/www/gitlist/config.ini
RUN sed -i 's#/home/git/repositories/#/repos/#g' /var/www/gitlist/config.ini
RUN sed -i "s#; timezone = UTC#timezone = $TZ#g" /var/www/gitlist/config.ini
RUN sed -i "s#; format = 'd/m/Y H:i:s'#format = 'd/m/Y H:i:s'#g" /var/www/gitlist/config.ini
WORKDIR /var/www/gitlist/
ADD nginx.conf /etc/

CMD service php5-fpm restart; nginx -c /etc/nginx.conf