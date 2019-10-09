#!/usr/bin/env bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! docker inspect judge-dev-chroot > /dev/null 2> /dev/null ; then
        docker volume create judge-dev-chroot > /dev/null
    fi
else
    cd dev-data || exit 1
    mkdir -p -m 777 chroot
fi
