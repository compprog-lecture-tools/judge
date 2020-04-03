# Deployment configuration

Files for easy deployment.
This is separated into deployment for a server running the web server and database, and another running judgehosts.


## HPI deployment

Unfortunately Docker's default subnet for container networking (`172.17.0.0/16`) interferes with internal HPI IPs, leading to being unable to connect to the server (via SSH) again, because it reponses of the OpenSSH server are being routed into the Docker subnet. Therefore **it is necessary** to configure Docker's default bridge IP in `/etc/docker/daemon.json` to another subnet (i.e. setting `bip` to `10.151.0.1/24`).

Full `/etc/docker/daemon.json`:
```json
{
	"bip": "10.151.0.1/24"
}
```
