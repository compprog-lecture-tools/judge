# Production Docker containers

This directory contains the build requirements for the two production containers.

## Web container (`hpiicpc/judge-web`)

This container runs the web server.
It needs access to a mariadb database and exposes the web server at port 80.
It can be configured using the following environment variables:
 * `CONTAINER_TIMEZONE` (default `Europe/Amsterdam`): Timezone used for the web server.
 * `MYSQL_HOST`: Host on which the mariadb database is reachable.
 * `MYSQL_USER`: User with which to connect to the judge database.
 * `MYSQL_PASSWORD`: Password for the `MYSQL_USER` user.
 * `MYSQL_ROOT_PASSWORD`: Root password for the mariadb database.
 * `MYSQL_DATABASE`: Database to use for storing the judge data.
 * `DJ_DB_INSTALL_BARE` (default `0`): Set to `1` to skip installing default data (problems/contests/...).
   Internally changes from running `make install` to `make bare-install`.
 * `FPM_MAX_CHILDREN` (defaults to 40): The maximum number of PHP-FPM processes.
 * `WEB_PREFIX` (defaults to `/`): Prefix for all paths.
   If not set up correctly, some links in the pages will not work correctly.
 
Both database passwords can also be specified by setting a `*_FILE` variant of their env variable to a file mounted on the container which contains the password.

## Judgehost container (`hpiicpc/judge-judgehost`)

This container is used to run judgehosts.
It needs access to the web server at a given URL, and pins itself to a single CPU core using cgroups.

When starting the container, one should use both the `--privileged` flag and mount the cgroup directory with `-v /sys/fs/cgroup:/sys/fs/cgroup` to allow the container to work with cgroups.
It should also be given a hostname with `--hostname`, as the judgehost name in the web interface will be based on the this.
The containers identify themselves by their hostname as well, so no two judgehosts should have the same hostname.

It can be configured using the following environment variables:
 * `CONTAINER_TIMEZONE` (default `Europe/Amsterdam`): Timezone used for the judgehost.
 * `DOMSERVER_BASEURL` (default `http://domserver/`): URL of the web server for which to run judgings.
   Must include a trailing slash!
 * `JUDGEDAEMON_USERNAME` (default `judgehost`): Username with which to authenticate to the web server.
 * `JUDGEDAEMON_PASSWORD`: Password with which to authenticate to the web server.
 * `DAEMON_ID` (default `0`): Id of the judgehost.
   Each judgehost on the same host should have a different id.
   This is also the zero-indexed number of the CPU core the judgehost will use for judgings!
