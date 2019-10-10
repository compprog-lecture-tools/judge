#!/usr/bin/env bash
set -e


REPO_ROOT="$(realpath "$(dirname "$0")/../..")"

if [[ -n "$(git -C "${REPO_ROOT}" status --porcelain domjudge)" ]]; then
    echo "Uncommitted changes in the domjudge directory won't be reflected in build containers" >&2
    echo 'If you want this, stash the changes before building' >&2
    exit 1
fi
if ! docker image inspect hpiicpc/judge-dev:latest > /dev/null; then
    echo 'Docker image hpiicpc/judge-dev:latest required for building'
    exit 1
fi

cd "${REPO_ROOT}/docker/prod"
touch web/web.tar web/docs.tar judgehost/judgehost.tar judgehost/chroot.tar
cleanup() {
    rm -f web/web.tar web/docs.tar judgehost/judgehost.tar judgehost/chroot.tar
}
trap cleanup EXIT

echo 'Building install archives...'
git -C "${REPO_ROOT}" archive --format=tar HEAD:domjudge | \
    docker run --rm -i --privileged \
        -v "$(realpath build-archives.sh):/build.sh:ro" \
        -v "$(realpath web/web.tar):/web.tar" \
        -v "$(realpath web/docs.tar):/docs.tar" \
        -v "$(realpath judgehost/judgehost.tar):/judgehost.tar" \
        -v "$(realpath judgehost/chroot.tar):/chroot.tar" \
        hpiicpc/judge-dev:latest /build.sh

echo 'Building web server image...'
docker build -t hpiicpc/judge-web:latest ${CI+--cache-from hpiicpc/judge-web:latest} web

echo 'Building judgehost image...'
docker build -t hpiicpc/judge-judgehost:latest ${CI+--cache-from hpiicpc/judge-judgehost:latest} judgehost
