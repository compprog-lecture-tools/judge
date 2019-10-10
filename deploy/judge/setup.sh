#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(dirname "$0")"

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
fi

echo -n 'Checking for requirements...'
if [[ ! -x "$(command -v docker)" ]]; then
    echo
    echo "Error: Docker is not installed." >&2
    exit 1
fi
if [[ ! -x "$(command -v systemctl)" ]]; then
    echo
    echo "Error: Systemd is not installed." >&2
    exit 1
fi
echo '  done'

read -r -p 'Base directory for installation (/opt/judge/judgehost): ' BASE_DIR
BASE_DIR="${BASE_DIR:-/opt/judge/judgehost}"
read -r -p 'Timezone for judgehost: ' TIMEZONE
read -r -p 'URL at which the web server is reachable (http://domserver/): ' WEB_BASEURL
WEB_BASEURL="${WEB_BASEURL:-http://domserver/}"
read -r -s -p 'Judgehost user password: ' JUDGEHOST_PASSWORD
echo

echo -n 'Creating base directory...'
${SUDO} mkdir -p "${BASE_DIR}"
${SUDO} chown "${USER}:${USER}" "${BASE_DIR}"
echo '  done'

echo -n 'Creating and protecting password file...'
${SUDO} touch "${BASE_DIR}/judgehost.password"
${SUDO} chmod 700 "${BASE_DIR}/judgehost.password"
echo "${JUDGEHOST_PASSWORD}" | ${SUDO} tee "${BASE_DIR}/judgehost.password" > /dev/null
echo '  done'

echo -n 'Installing systemd units to /lib/systemd/system...'
sed -e "s|%BASEDIR%|${BASE_DIR}|g" \
    -e "s|%WEB_BASEURL%|${WEB_BASEURL}|g" \
    -e "s|%TIMEZONE%|${TIMEZONE}|g" \
    "${SCRIPT_DIR}/judge-judgehost@.service" \
| ${SUDO} tee "/lib/systemd/system/judge-judgehost@.service" > /dev/null
echo '  done'

echo -n 'Reloading systemd daemon to install units...'
${SUDO} systemctl daemon-reload
echo '  done'

cat <<EOF

Automatic installation complete. As the next steps, you should:

1. Start a judgehost: systemctl start judge-judgehost@0
   The number after the @ signals the CPU core to use for judging and also acts as an id.

2. Enable judgehosts to start automatically: systemctl enable judge-judgehost@0 ...
EOF
