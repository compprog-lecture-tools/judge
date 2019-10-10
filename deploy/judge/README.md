# Judgehost server deployment

Running `setup.sh` will install the deployment into a base directory (default is `/opt/judge/web`) and a systemd unit for judgehosts into `/lib/systemd/system`.
In the base directory, a `judgehost.password` file will be created containing the password of the `judgehost` account on the web server.
It will only be accessible by `root`.
