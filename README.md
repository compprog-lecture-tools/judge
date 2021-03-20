# HPIjudge

Competitive programming judge system based on DOMjudge 7.3.2, developed for use at HPI.

This contains:
 * the customized DOMjudge sources in `domjudge`,
 * docker containers for development and production in `docker` (based on the ones in [domjudge-packaging](https://github.com/DOMjudge/domjudge-packaging)),
 * deployment scripts and settings in `deploy`,
 * and several make targets for easier development
 
## Development

Note: If you are just developing problems, there is a guide to set up a local judge in the problem repo.
This section is for developing the judge itself.

For development, you will need Docker, Git and Bash.
On some systems you will have to install the `realpath` tool, which is required for some scripts.
On Linux you will also have to enable cgroups (usually already active) and enable memory limits imposed by them (see [this](https://askubuntu.com/a/417221) for how, it should be applicable for any system using Grub).

During development, you will use the `judge-dev` container.
It is quite slow, but it reflects changes to the source files immediately, which is immensely helpful.
You only need to restart it if you have changed the database structure (migrations are run automatically on startup).

You can build it using `make build-dev`, but unless you changed something in the containers definition, you probably want to download it using `docker pull hpiicpc/judge-dev` instead.
To start the container, run `make start-dev`.
This will also download a mariadb container on the first run, which is used for a local development database.
Use `docker logs -f judge-dev` to follow the startup process.
This can take a bit, especially on the first run.

Once the web interface is running and reachable at http://localhost:8080, you probably want to run `make setup-dev-settings`.
This sets several settings to the values used for the main judge, and also creates four accounts for testing, creatively named `test`, `test2`, `test3` and `test4`.
These are set up as admins as well as team and jury members, so they basically have access to everything inside the judge.
Their passwords are equal to their respective usernames.
You will only have to redo this step should you delete the local database (see the readme in `dev-data` on that).

Once you are done, you can stop the containers with `make stop-dev`.

## Production

To build the production containers, run `make build-prod`.
For technical reasons, this requires the dev container, so make sure to either pull or build it.
The build step only takes committed changes in the `domjudge` directory into account, so you will have to stash any uncommited ones you want to ignore (the script will tell you this as well).

For deployment read the readmes in the `deploy` directory, and its `web` and `judgehost` sub-directories.
 
## Changes from base DOMjudge

The following broad changes were made to the DOMjudge sources:
 * Added setting to show teams the source code of their own submissions
 * Added setting to disable clarifications
 * HPI styling and links to imprint page
 * Added C++17 language
 * Added data fixtures containing the settings for production and some development conveniences
 * Added contests sorted by runtime (after sorting by number of problems solved)
 
### Upgrading to a newer DOMjudge version

The DOMjudge source in `domjudge` was included using git subtree.
To update to a newer version, run
```bash
git subtree pull -P domjudge --squash git@github.com:DOMjudge/domjudge.git <version>
```
Here, `<version>` should be the git commit hash for a release.
Do not use tag names as that causes problems the next time you update (you will need to manually pull the tags from the DOMjudge repo).
This will squash all changes since the last version into one commit, and then start a merge into the current branch.
If something fundamental changed, the docker containers and their startup scripts might also need to be updated.
For this, manual comparison with the [domjudge-packaging](https://github.com/DOMjudge/domjudge-packaging) is required.
