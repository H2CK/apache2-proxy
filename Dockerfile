FROM phusion/baseimage:latest

# Set correct environment variables
ENV DEBIAN_FRONTEND="noninteractive" HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

ADD setup.sh /tmp/
RUN bash /tmp/setup.sh
       
#Add Apache configuration
RUN a2enmod ssl \
	&& a2enmod proxy \
	&& a2enmod proxy_http \
	&& a2enmod proxy_balancer \
	&& a2enmod lbmethod_byrequests \
	&& a2enmod proxy_wstunnel \
	&& a2enmod rewrite \
	&& a2enmod headers \
	&& a2enmod auth-openidc \
	&& a2enmod wsgi \
	&& a2dissite 000-default 

VOLUME /etc/apache2/sites-enabled /etc/letsencrypt

EXPOSE 80/tcp 443/tcp
