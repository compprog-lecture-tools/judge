FROM debian:latest
MAINTAINER DOMjudge team <team@domjudge.org>

ENV DEBIAN_FRONTEND=noninteractive \
	CONTAINER_TIMEZONE=Europe/Amsterdam \
	MYSQL_HOST=mariadb \
	MYSQL_USER=domjudge \
	MYSQL_DATABASE=domjudge \
	MYSQL_PASSWORD=domjudge \
	MYSQL_ROOT_PASSWORD=domjudge \
	FPM_MAX_CHILDREN=40 \
	DJ_DB_INSTALL_BARE=0

# Install required packages for running of domserver
RUN apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
	zip unzip acl supervisor mariadb-client apache2-utils \
	nginx php-cli php-fpm php-zip \
	php-gd php-curl php-mysql php-json php-intl \
	php-gmp php-xml php-mbstring php-ldap \
	enscript lpr \
	&& rm -rf /var/lib/apt/lists/*

# Install composer
ADD https://getcomposer.org/installer composer-setup.php
RUN php composer-setup.php \
    && mv /composer.phar /usr/local/bin/composer

# Add domserver directory and script files
ADD web.tar /
ADD docs.tar /
COPY ["scripts", "/scripts/"]

# Add user, create PHP FPM socket dir, change permissions for domjudge directory and fix scripts
RUN useradd -m domjudge \
	&& mkdir -p /run/php \
	&& chown -R domjudge: /opt/domjudge \
	&& chown -R www-data: /opt/domjudge/domserver/tmp \
	&& chown -R www-data: /opt/domjudge/domserver/submissions \
	&& chmod 755 /scripts/start.sh \
	&& chmod 755 /scripts/bin/* \
	&& ln -s /scripts/bin/* /usr/bin/
CMD ["/scripts/start.sh"]

# Copy supervisor files
COPY ["supervisor", "/etc/supervisor/conf.d/"]

# Expose HTTP port
EXPOSE 80
