FROM ubuntu:14.04
RUN apt-get update && \
  apt-get -y install git nginx-full php5-fpm curl apache2-utils
ADD https://github.com/klaussilveira/gitlist/releases/download/1.0.2/gitlist-1.0.2.tar.gz /var/www/
RUN tar -zxvf /var/www/gitlist-1.0.2.tar.gz -C /var/www && \
  rm /var/www/gitlist-1.0.2.tar.gz && \
  mkdir /var/www/gitlist/cache && \
  chmod -R 777 /var/www/gitlist
WORKDIR /var/www/gitlist/
ADD nginx.conf /etc/
ADD docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
EXPOSE 80
VOLUME ["/repos", "/repos2", "/repos3", "/repos4", "/repos5"]
ENTRYPOINT ["/docker-entrypoint.sh"]
