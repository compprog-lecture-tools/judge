FROM debian:buster
MAINTAINER DOMjudge team <team@domjudge.org>

ENV DEBIAN_FRONTEND=noninteractive \
	CONTAINER_TIMEZONE=Europe/Amsterdam \
	DOMSERVER_BASEURL=http://domserver/ \
	JUDGEDAEMON_USERNAME=judgehost \
	JUDGEDAEMON_PASSWORD=password \
	DAEMON_ID=0 \
	DOMJUDGE_CREATE_WRITABLE_TEMP_DIR=0 \
	RUN_USER_UID_GID=62860

# Install required packages for running of judgehost
RUN apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
	zip unzip acl supervisor sudo procps libcgroup1 \
	php-cli php-zip php-gd php-curl php-mysql php-json \
	php-gmp php-xml php-mbstring python3 \
	gcc g++ default-jre-headless default-jdk ghc fp-compiler \
	&& rm -rf /var/lib/apt/lists/*

# Add chroot and judgehost data
ADD chroot.tar /
ADD judgehost.tar /
RUN cp /opt/domjudge/judgehost/etc/sudoers-domjudge /etc/sudoers.d/

# Add scripts
COPY ["scripts", "/scripts/"]

# Change start script permissions, add user and fix permissions
RUN chmod +x /scripts/start.sh \
	&& useradd -m domjudge \
	&& chown -R domjudge: /opt/domjudge
CMD ["/scripts/start.sh"]
