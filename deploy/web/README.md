# Web server deployment

Running `setup.sh` will install the deployment into a base directory (default is `/opt/judge/web`).

It will set up:
* Systemd service units for the mariadb (`mariadb.service`) and judge web server (`judge-web.service`) containers
* A private docker network for the two containers
* A `restart-server.sh` utility script which restarts the web server without restarting the entire docker container
* A database backup script available as a systemd unit (`judge-backup-db.service`), run automatically at 3am each day by a systemd timer (`judge-backup-db.timer`).
  See below for details.
* A mariadb config directory (`<base-dir>/db/conf.d`) with some sensible defaults

## Database backups

Running `systemctl start judge-backup-db.service` creates a database backup in `<base-dir>/db/backups/<day>`.
This is run automatically each day at 3am by a corresponding timer.
The first backup of each day is full, the following are incremental based on previous one.
Only backups of the three newest days are kept.

## Affiliation logos

The `<base-dir>/affiliations` is mounted as  `webapp/public/images/affiliation`, and thus can be used to to supply affiliation logos.
Each logo must be named `<id>.png`, where `id` is the numeric id of the affiliation (*not* the shortname!).
