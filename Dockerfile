FROM ubuntu:22.04

# Set correct environment variables
ENV DEBIAN_FRONTEND="noninteractive" HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
ENV supervisor_conf /etc/supervisor/supervisord.conf
ENV security_conf /etc/apache2/conf-available/security.conf
ENV start_scripts_path /bin

# Update packages from baseimage
RUN apt-get update -qq
# Install and activate necessary software #neplan.io \
RUN apt-get upgrade -qy && apt-get install -qy \
    apt-utils \
    cron \
    supervisor \
    apache2 \
    apache2-utils \
    libexpat1 \
    libcjose0 \
    libcurl4 \
    libjansson4 \
    ssl-cert \
    python3 \
    php \
    php-fpm \
    php-mysql \
    certbot \
    python3-certbot-apache \
    wget \
    && a2dismod php8.1 \
    && a2dismod mpm_prefork \
    && a2enmod mpm_event \
    && a2enmod ssl \
    && a2enmod http2 \
    && a2enmod proxy \
    && a2enmod proxy_http \
    && a2enmod proxy_balancer \
    && a2enmod lbmethod_byrequests \
    && a2enmod proxy_wstunnel \
    && a2enmod rewrite \
    && a2enmod headers \
    && a2enmod proxy_fcgi setenvif \
    && a2enconf php8.1-fpm \
    && a2dissite 000-default \
    && mkdir /var/www/letsencrypt \
    && mkdir /var/www/letsencrypt/.well-known \
    && chown -R www-data:www-data /var/www/letsencrypt \
    && chmod -R 750 /var/www/letsencrypt/.well-known \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/* \
    && groupadd docker-data \
    && usermod -a -G docker-data,adm www-data

## libapache2-mod-auth-openidc \
## && a2enmod auth_openidc \

COPY supervisord.conf ${supervisor_conf}
COPY security.conf ${security_conf}
COPY 01_user_config.sh ${start_scripts_path}
COPY 02_auto_update.sh ${start_scripts_path}
COPY 03_set_a2port.sh ${start_scripts_path}
COPY start.sh /start.sh
RUN chmod +x ${start_scripts_path}/01_user_config.sh \
    && chmod +x ${start_scripts_path}/02_auto_update.sh \
    && chmod +x ${start_scripts_path}/03_set_a2port.sh \
    && chmod +x /start.sh

CMD ["./start.sh"]
       
VOLUME /etc/apache2/sites-enabled /etc/letsencrypt

EXPOSE 80/tcp 443/tcp
