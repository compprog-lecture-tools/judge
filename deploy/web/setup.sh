#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(dirname "$0")"

SUDO=""
if [[ "$(id -u)" -ne "0" ]]; then
    SUDO="sudo"
fi

echo -n 'Checking for requirements...'
if [[ ! -x "$(command -v docker)" ]]; then
    echo
    echo "Error: Docker is not installed." >&2
    exit 1
fi
if [[ ! -x "$(command -v python3)" ]]; then
    echo
    echo "Error: Python 3.6+ is not installed." >&2
    exit 1
elif [[ "$(python3 -c 'import sys; print(sys.version_info >= (3, 6))')" == 'False' ]]; then
    echo
    echo "Error: Python 3.6+ required." >&2
    exit 1
fi
if [[ ! -x "$(command -v systemctl)" ]]; then
    echo
    echo "Error: Systemd is not installed." >&2
    exit 1
fi
echo '  done'

read -r -p 'Base directory for installation (/opt/judge/web): ' BASE_DIR
BASE_DIR="${BASE_DIR:-/opt/judge/web}"
read -r -p 'Port for the web server: ' PORT
read -r -p 'Timezone for web server: ' TIMEZONE
read -r -p 'Base path for the web server (/domjudge): ' WEB_PREFIX
WEB_PREFIX="${WEB_PREFIX:-/domjudge}"
read -r -p 'Subnet for the docker network (leave empty for default): ' DOCKER_SUBNET
read -r -s -p 'Database password: ' DB_PASSWORD
echo
read -r -s -p 'Database root password: ' DB_ROOT_PASSWORD
echo
read -r -s -p 'Database backup password: ' DB_BACKUP_PASSWORD
echo
read -r -s -p 'Database readonly user password: ' DB_READONLY_PASSWORD
echo

echo -n 'Creating base directory...'
${SUDO} mkdir -p "${BASE_DIR}"
${SUDO} chown "${USER}:${USER}" "${BASE_DIR}"
echo '  done'

echo -n 'Creating and protecting secrets directory...'
mkdir "${BASE_DIR}/secrets"
${SUDO} chown root:root "${BASE_DIR}/secrets"
${SUDO} chmod 700 "${BASE_DIR}/secrets"
echo "${DB_PASSWORD}" | ${SUDO} tee "${BASE_DIR}/secrets/db.password" > /dev/null
echo "${DB_ROOT_PASSWORD}" | ${SUDO} tee "${BASE_DIR}/secrets/db-root.password" > /dev/null
echo "${DB_BACKUP_PASSWORD}" | ${SUDO} tee "${BASE_DIR}/secrets/db-backup.password" > /dev/null
echo "${DB_READONLY_PASSWORD}" | ${SUDO} tee "${BASE_DIR}/secrets/db-readonly.password" > /dev/null
echo '  done'

echo -n 'Installing systemd units to /lib/systemd/system...'
for UNIT_FILE in "${SCRIPT_DIR}"/units/*.service "${SCRIPT_DIR}"/units/*.timer; do
    sed -e "s|%BASEDIR%|${BASE_DIR}|g" \
        -e "s|%PORT%|${PORT}|g" \
        -e "s|%TIMEZONE%|${TIMEZONE}|g" \
        -e "s|%WEB_PREFIX%|${WEB_PREFIX}|g" \
        "${UNIT_FILE}" \
    | ${SUDO} tee "/lib/systemd/system/$(basename "${UNIT_FILE}")" > /dev/null
done
echo '  done'

echo -n 'Copying scripts over...'
cp -r "${SCRIPT_DIR}/scripts" "${BASE_DIR}/scripts"
echo '  done'

echo -n 'Setting up database directory...'
mkdir -p "${BASE_DIR}/db/data"
mkdir -p "${BASE_DIR}/db/conf.d"
mkdir -p "${BASE_DIR}/db/backups"
cp "${SCRIPT_DIR}/default.cnf" "${BASE_DIR}/db/conf.d"
echo '  done'

echo -n 'Creating docker network...'
${SUDO} docker network create ${DOCKER_SUBNET:+--subnet "${DOCKER_SUBNET}"} judge-web > /dev/null
echo '  done'

echo -n 'Reloading systemd daemon to install units...'
${SUDO} systemctl daemon-reload
echo '  done'

cat <<EOF

Automatic installation complete. As the next steps, you should:

1. Start the services: systemctl start mariadb judge-web judge-backup-db.timer
   The web interface should then be reachable at http://this-server:${PORT}${WEB_PREFIX}.

2. Enable the services to start automatically: systemctl enable mariadb judge-web judge-backup-db.timer

3. Find the initial admin password in the log output (journalctl -u judge-web)

4. Change the admin and judgehost password, as well as create other admin users to your liking.

5. Run docker exec judge-web /opt/domjudge/domserver/webapp/bin/console doctrine:fixture:load --append --group=HpiSettingsFixture  to setup the usual HPI settings (languages, etc.)
EOF
