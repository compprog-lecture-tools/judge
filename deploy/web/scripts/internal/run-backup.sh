#!/usr/bin/env bash

# shellcheck disable=SC2086
mariabackup --backup \
    --target-dir="/backups/$1" \
    ${2:+"--incremental-basedir=/backups/$2"} \
    --user=mariabackup \
    --password="$(cat /secrets/db-backup.password)"
