# Docker containers

This directory contains docker containers for both development and production.
They are based on the containers from the [domjudge-packaging](https://github.com/DOMjudge/domjudge-packaging) repository at commit `dbd61c1`.
The `dev` directory is based on the `docker-contributor` directory from that repository, and `prod` on `docker`.

The changes made from that are:

 * Enable building from source instead of a release archive
 * Combine archive building steps for web and judgehost containers
 * Add `WEB_PREFIX` option
