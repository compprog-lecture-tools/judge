#!/usr/bin/env bash
echo 'Creating additional database users...'
mysql -uroot -p"$(cat /secrets/db-root.password)" <<-EOF
    CREATE USER 'mariabackup'@'%' IDENTIFIED BY '$(cat /secrets/db-backup.password)';
    GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'mariabackup'@'%';
    CREATE USER 'domjudge-readonly'@'%' IDENTIFIED BY '$(cat /secrets/db-readonly.password)';
    GRANT SELECT ON domjudge.* TO 'domjudge-readonly'@'%';
EOF
