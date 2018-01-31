#!/bin/bash

export DEBIAN_FRONTEND="noninteractive"

groupadd docker-data 
usermod -a -G docker-data,adm www-data

# user config
cat <<'EOT' > /etc/my_init.d/01_user_config.sh
#!/bin/bash
GROUPID=${GROUP_ID:-999}
groupmod -g $GROUPID docker-data 
EOT

# auto update
cat <<'EOT' > /etc/my_init.d/02_auto_update.sh
#!/bin/bash
apt-get update -qq
apt-get upgrade -qy
EOT

#set Port for Apache to listen to
cat <<'EOT' > /etc/my_init.d/03_set_a2port.sh
#!/bin/bash
A2HTTPPORT=${HTTP_PORT:-80}
A2HTTPSPORT=${HTTPS_PORT:-443}
echo "Listen *:$A2HTTPPORT" > /etc/apache2/p1.conf
echo "Listen *:$A2HTTPSPORT" > /etc/apache2/p2.conf
cat /etc/apache2/p1.conf /etc/apache2/p2.conf > /etc/apache2/ports.conf
rm /etc/apache2/p1.conf
rm /etc/apache2/p2.conf
EOT

# Apache Startup Script
mkdir -p /etc/service/apache2
cat <<'EOT' > /etc/service/apache2/run
#!/bin/bash
exec /sbin/setuser root /usr/sbin/apache2ctl -DFOREGROUND 2>&1
EOT

mkdir /usr/share/external
chmod 777 /usr/share/external
chmod -R +x /etc/service/ /etc/my_init.d/ /var/bin/

apt-get update -qq
apt-get upgrade -qy
apt-get install -qy \
    apache2 \
    apache2-utils \
    libexpat1 \
    ssl-cert \
    libapache2-mod-auth-openidc \
    python \
    libapache2-mod-wsgi \
    python-redis \
    python-passlib

apt-get install -qy software-properties-common
add-apt-repository ppa:certbot/certbot
apt-get update -qq
apt-get install -qy certbot

mkdir /var/www/letsencrypt
mkdir /var/www/letsencrypt/.well-known
chown -R www-data:www-data /var/www/letsencrypt
chmod -R 750 /var/www/letsencrypt/.well-known

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/*
