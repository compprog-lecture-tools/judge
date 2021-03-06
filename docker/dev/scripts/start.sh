#!/bin/bash -e

function file_or_env {
    file=${1}_FILE
    if [ ! -z "${!file}" ]; then
        cat "${!file}"
    else
        echo -n ${!1}
    fi
}

echo "[..] Setting timezone"
ln -snf /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime
echo ${CONTAINER_TIMEZONE} > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
echo "[ok] Container timezone set to: ${CONTAINER_TIMEZONE}"; echo

echo "[..] Changing nginx and PHP configuration settings"
# Set correct settings
sed -ri -e "s/^user.*/user domjudge;/" /etc/nginx/nginx.conf
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = 100M/" \
    -e "s/^post_max_size.*/post_max_size = 100M/" \
    -e "s/^memory_limit.*/memory_limit = 2G/" \
    -e "s/^max_file_uploads.*/max_file_uploads = 200/" \
    -e "s#^;date\.timezone.*#date.timezone = ${CONTAINER_TIMEZONE}#" \
     /etc/php/7.3/fpm/php.ini
sed -ri -e "s#^;date\.timezone.*#date.timezone = ${CONTAINER_TIMEZONE}#" \
     /etc/php/7.3/cli/php.ini
echo "[ok] Done changing nginx and PHP configuration settings"; echo

cd /domjudge

# Determine whether we have a legacy DOMjudge instance, i.e. one without Symfony
USE_LEGACY=0
if [[ ! -d webapp ]]
then
  USE_LEGACY=1
fi

if [[ ! -f README.md ]] || ! grep -q DOMjudge README.md
then
  echo "DOMjudge sources not found. Did you add a volume with your DOMjudge checkout at /domjudge?"
  exit 1
fi

MYSQL_PASSWORD=$(file_or_env MYSQL_PASSWORD)
MYSQL_ROOT_PASSWORD=$(file_or_env MYSQL_ROOT_PASSWORD)

cat > /home/domjudge/.my.cnf <<EOF
[client]
host=${MYSQL_HOST}
user=root
password=${MYSQL_ROOT_PASSWORD}
EOF
chown domjudge: /home/domjudge/.my.cnf

echo "[..] Updating database credentials file"
echo "dummy:${MYSQL_HOST}:${MYSQL_DATABASE}:${MYSQL_USER}:${MYSQL_PASSWORD}" > etc/dbpasswords.secret
echo "[ok] Updated database credentials file"; echo

if [ "${DJ_SKIP_MAKE}" -eq "1" ]
then
  echo "Skipping maintainer-mode install for DOMjudge"
else
  echo "[..] Performing maintainer-mode install for DOMjudge"
  sudo -u domjudge make maintainer-conf CONFIGURE_FLAGS="--with-baseurl=http://localhost/ --with-webserver-group=domjudge"
  sudo -u domjudge make maintainer-install
  echo "[ok] DOMjudge installed in Maintainer-mode"; echo
fi

echo "[..] Setting up bind mount and correct permissions for judgings"
mkdir -p /domjudge-judgings
mount -o bind /domjudge-judgings /domjudge/output/judgings
chown -R domjudge output
echo "[ok] Done setting up permissions"

echo "[..] Checking database connection"
if ! mysqlshow -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h${MYSQL_HOST} ${MYSQL_DATABASE} > /dev/null 2>&1
then
  echo "MySQL database ${MYSQL_DATABASE} not found on host ${MYSQL_HOST}; exiting"
  exit 1
fi

if ! bin/dj_setup_database -uroot -p${MYSQL_ROOT_PASSWORD} status > /dev/null 2>&1
then
  echo "  Database not installed; installing..."
  INSTALL=install
  if [ "${DJ_DB_INSTALL_BARE}" -eq "1" ]
  then
    INSTALL=bare-install
  fi
  echo "Using ${INSTALL}..."
  bin/dj_setup_database -uroot -p${MYSQL_ROOT_PASSWORD} ${INSTALL}
else
  echo "  Database installed; upgrading..."
  bin/dj_setup_database -uroot -p${MYSQL_ROOT_PASSWORD} upgrade
fi
echo "[ok] Database ready"; echo

echo "[..] Fixing restapi path"
sed -i 's/localhost\/domjudge/localhost/' etc/restapi.secret
echo "[ok] Changed restapi URL from http://localhost/domjudge to http://localhost"

echo "[..] Copying webserver config"
# Set up vhost
cp etc/nginx-conf /etc/nginx/sites-enabled/default
# Replace nginx php socket location
sed -i 's/server unix:.*/server unix:\/var\/run\/php-fpm-domjudge.sock;/' /etc/nginx/sites-enabled/default
# Remove default FPM pool config and link in DOMJudge version
if [[ -f /etc/php/7.3/fpm/pool.d/www.conf ]]
then
  rm /etc/php/7.3/fpm/pool.d/www.conf
fi
if [[ ! -f /etc/php/7.3/fpm/pool.d/domjudge.conf ]]
then
  ln -s /domjudge/etc/domjudge-fpm.conf /etc/php/7.3/fpm/pool.d/domjudge.conf
fi
# Change pm.max_children
sed -i "s/^pm\.max_children = .*$/pm.max_children = ${FPM_MAX_CHILDREN}/" /etc/php/7.3/fpm/pool.d/domjudge.conf

chown domjudge: /domjudge/etc/dbpasswords.secret
chown domjudge: /domjudge/etc/restapi.secret
if [[ "${USE_LEGACY}" -eq "0" ]]
then
  HAS_INNER_NGINX=0
  NGINX_CONFIG_FILE=/etc/nginx/sites-enabled/default

  # Check if we are on DOMjudge >= bb8209d4e9596b9480c1f85960dfb7c3d763b587 which has a separate file for the inner nginx configuration
  if [[ -f etc/nginx-conf-inner ]]
  then
    HAS_INNER_NGINX=1
    cp etc/nginx-conf-inner /etc/nginx/snippets/domjudge-inner
    NGINX_CONFIG_FILE=/etc/nginx/snippets/domjudge-inner
    sed -i 's/\/domjudge\/etc\/nginx-conf-inner/\/etc\/nginx\/snippets\/domjudge-inner/' /etc/nginx/sites-enabled/default
    # Run DOMjudge in root
    sed -i '/^# location \//,/^# \}/ s/# //' $NGINX_CONFIG_FILE
    sed -i '/^location \/domjudge/,/^\}/ s/^/#/' $NGINX_CONFIG_FILE
    sed -i 's/\/domjudge;/"";/' $NGINX_CONFIG_FILE
  else
    # Run DOMjudge in root
    sed -i '/^\t#location \//,/^\t#\}/ s/\t#/\t/' $NGINX_CONFIG_FILE
    sed -i '/^\tlocation \/domjudge/,/^\t\}/ s/^\t/\t#/' $NGINX_CONFIG_FILE
  fi
  # Remove access_log and error_log entries
  sed -i '/access_log/d' $NGINX_CONFIG_FILE
  sed -i '/error_log/d' $NGINX_CONFIG_FILE
  # Use debug front controller
  sed -i 's/app\.php/app_dev.php/g' $NGINX_CONFIG_FILE
  sed -i 's/app\\\.php/app\\_dev.php/g' $NGINX_CONFIG_FILE
  # Set up permissions (make sure the script does not stop if this fails, as this will happen on macOS / Windows)
  chown domjudge: /domjudge/webapp/var
fi
echo "[ok] Webserver config installed"; echo

if [[ ! -d /chroot/domjudge ]]
then
  echo "[..] Setting up chroot"
  bin/dj_make_chroot -D Debian -R buster
  echo "[ok] Done setting up chroot"; echo
fi

echo "[..] Setting up cgroups"
judge/create_cgroups
echo "[ok] cgroups set up"; echo

echo "[..] Adding sudoers configuration"
cp etc/sudoers-domjudge /etc/sudoers.d/
echo "[ok] Sudoers configuration added"; echo

exec supervisord -n -c /etc/supervisor/supervisord.conf
