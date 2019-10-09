#!/usr/bin/env bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    if docker inspect judge-dev-chroot > /dev/null 2> /dev/null ; then
        docker volume rm judge-dev-chroot > /dev/null
    fi
else
    rm -rf dev-data/chroot
fi
