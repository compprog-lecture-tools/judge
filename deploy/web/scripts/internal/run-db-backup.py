#!/usr/bin/env python3
import datetime
import pathlib
import shutil
import subprocess
import sys

BACKUP_DAYS_TO_KEEP = 3

def select_backup_dirs(base_dir, date):
    date_dir = base_dir / date.isoformat()
    date_dir.mkdir(exist_ok=True)
    backup_dir = date_dir / '0000 - full'
    incremental_base_dir = None
    backup_idx = 0
    while backup_dir.exists():
        backup_idx += 1
        incremental_base_dir = backup_dir
        backup_dir = date_dir / f'{backup_idx:04} - incremental'
    backup_dir.mkdir()
    return backup_dir, incremental_base_dir


def run_backup(container_name, base_dir, backup_dir, incremental_base_dir):
    backup_dir_rel = str(backup_dir.relative_to(base_dir))
    if incremental_base_dir is None:
        print(f'Running full backup into "{backup_dir_rel}"...')
        incremental_base_dir_rel = ''
    else:
        print(f'Running incremental backup into "{backup_dir_rel}"...')
        incremental_base_dir_rel = incremental_base_dir.relative_to(base_dir)
    subprocess.run([
        'docker', 'exec', container_name, '/run-backup.sh', backup_dir_rel,
        incremental_base_dir_rel
    ], check=True)


def prune_old_backups(base_dir):
    backup_dirs = []
    for item in base_dir.iterdir():
        if not item.is_dir():
            continue
        try:
            backup_date = datetime.datetime.strptime(item.name, '%Y-%m-%d').date()
        except ValueError:
            continue
        backup_dirs.append((item, backup_date))
    backup_dirs.sort(key=lambda t: t[1])
    for backup_dir, _ in backup_dirs[:-BACKUP_DAYS_TO_KEEP]:
        print(f'  Pruning "{backup_dir.relative_to(base_dir)}"...')
        shutil.rmtree(backup_dir)


def main():
    if len(sys.argv) != 3:
        print(f'Usage: {sys.argv[0]} base_dir container_name', file=sys.stderr)
        sys.exit(1)

    base_dir = pathlib.Path(sys.argv[1])
    container_name = sys.argv[2]
    date = datetime.date.today()
    backup_dir, incremental_base_dir = select_backup_dirs(base_dir, date)
    run_backup(container_name, base_dir, backup_dir, incremental_base_dir)
    if incremental_base_dir is None:
        print('Pruning old backups...')
        prune_old_backups(base_dir)
    else:
        print('Incremental backup, skipping pruning of old backups')


main()
