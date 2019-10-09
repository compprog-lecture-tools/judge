#!/usr/bin/env bash
echo 'Starting mariadb container...'
docker run \
    -it \
    --rm \
    --detach \
    --name mariadb \
    -p 13306:3306 \
    -v "$(realpath ./dev-data/db):/var/lib/mysql" \
    -e MYSQL_ROOT_PASSWORD=domjudge \
    -e MYSQL_USER=domjudge \
    -e MYSQL_PASSWORD=domjudge \
    -e MYSQL_DATABASE=domjudge \
    mariadb:10.4 \
    --max-connections=1000 > /dev/null

# The dev container fails if the db server is not up once the web server
# is started. We ignore this here since the dev container takes so long
# to start up that this should never be a problem

if [[ "$OSTYPE" == "darwin"* ]]; then
    CHROOT_VOLUME="judge-dev-chroot"
    MAYBE_CACHED=":cached"
else
    CHROOT_VOLUME="$(realpath ./dev-data/chroot)"
fi

echo 'Starting dev container container...'
docker run \
    -it \
    --rm \
    --detach \
    --privileged \
    --name judge-dev \
    --hostname judge-dev \
    -p 8080:80 \
    --link mariadb:mariadb \
    -v "$(realpath ./domjudge):/domjudge${MAYBE_CACHED}" \
    -v "${CHROOT_VOLUME}:/chroot" \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    hpiicpc/judge-dev > /dev/null
