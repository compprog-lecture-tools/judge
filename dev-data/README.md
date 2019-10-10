This directory contains temporary data for development setups.
In particular:
 * `db`: Contains the mariadb database for the dev docker container
 * `chroot`: On Linux, this contains a cached version of the chroot created by the dev container.
   This speeds up the startup time a lot.
   On macOS a volume is used instead (see below for details).
 
Use the make targets `clear-db` and `clear-chroot` to clear these directorise and save space.

#### Chroot volume (macOS)

On macOS the chroot in the dev container cannot be created in a bind-mounted volume because the required filesystem features are not implemented.
Instead, a volume named `judge-dev-chroot` is created.
Its data is stored in the Linux VM used by Docker on macOS and is not accessible from the host system.
Running `make clear-chroot` resets this volume as well.
