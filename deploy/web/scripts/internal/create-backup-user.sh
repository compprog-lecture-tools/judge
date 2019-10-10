#!/usr/bin/env bash
echo 'Creating database backup user...'
mysql -uroot -p"$(cat /secrets/db-root.password)" <<-EOF
    CREATE USER 'mariabackup'@'%' IDENTIFIED BY '$(cat /secrets/db-backup.password)';
    GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'mariabackup'@'%';
EOF
