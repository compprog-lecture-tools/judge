#!/usr/bin/env bash
set -e

# Build archives for the web container and judgehost container Should be run in
# the dev container, or any other container with all the necessary tools for
# the build process installed.
#
# When run, a tar archive containing the contents of the domjudge directory
# should be passed to stdin. The archives will be build to /web.tar, /docs.tar,
# /chroot.tar and /judgehost.tar, which should be bind-mounted to appropriate
# locations.


# Unpack tar snapshot from stdin
mkdir /domjudge-src
cd /domjudge-src
cat | tar x
chown -R domjudge: .

# Create dist build
sudo -u domjudge make dist

# Configuring
USE_LEGACY=0
if [[ ! -d webapp ]]
then
  USE_LEGACY=1
fi
if [[ "${USE_LEGACY}" -eq "0" ]]
then
  echo "default	http://localhost/api	dummy	dummy" > etc/restapi.secret
else
  echo "default	http://localhost/api/v4	dummy	dummy" > etc/restapi.secret
fi
sudo -u domjudge ./configure -with-baseurl=http://localhost

# Build and install web server and docs
sudo -u domjudge make domserver
make install-domserver
sudo -u domjudge make docs
make install-docs

# Build and install judgehost
sudo -u domjudge make judgehost
make install-judgehost
if [[ "${USE_LEGACY}" -eq "1" ]]
then
  touch /opt/domjudge/judgehost/legacy
fi

# Build and install chroot
/opt/domjudge/judgehost/bin/dj_make_chroot -D Debian -R buster

# Pack archives
tar -cpf /web.tar /opt/domjudge/domserver
tar -cpf /docs.tar /opt/domjudge/doc
tar -cpf /judgehost.tar /opt/domjudge/judgehost
tar -cpf /chroot.tar /chroot
