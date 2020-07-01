FROM alpine:3.12
MAINTAINER Stefano Marinelli <stefano@dragas.it>

RUN apk add --no-cache \
  nginx supervisor php7-fpm php7 php7-curl php7-gd php7-json \
  php7-dom php7-intl php7-mbstring php7-mysqli php7-pgsql php7-pdo_pgsql php7-pdo_mysql php7-mcrypt php7-fileinfo php7-pcntl php7-posix php7-session curl

# add ttrss as the only nginx site
ADD ttrss.nginx.conf /etc/nginx/conf.d/ttrss.conf

# install ttrss and patch configuration
WORKDIR /var/www
RUN curl -SL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC /var/www --strip-components 1 \
    && apk del curl \
    && chown nobody:nobody -R /var/www && rm /etc/nginx/conf.d/default.conf && cp config.php-dist config.php && mkdir /run/php && mkdir /run/nginx/

# expose only nginx HTTP port
EXPOSE 80

# complete path to ttrss
ENV SELF_URL_PATH http://localhost

# expose default database credentials via ENV in order to ease overwriting
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

# always re-configure database with current ENV when RUNning container, then monitor all services
ADD configure-db.php /configure-db.php
ADD supervisord.conf /etc/supervisord.conf
CMD php /configure-db.php && supervisord -c /etc/supervisord.conf
