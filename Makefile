.PHONY: all
all:

ifndef VERBOSE
.SILENT:
endif

.PHONY: cached-chroot
cached-chroot:
	./make/setup-cached-chroot.sh

dev-data/db:
	mkdir -p -m 777 dev-data/db

.PHONY: setup-dev-data
setup-dev-data: cached-chroot dev-data/db

.PHONY: clear-db
clear-db:
	echo 'Deleting dev database...'
	rm -rf dev-data/db

.PHONY: clear-chroot
clear-chroot:
	echo 'Deleting dev chroot...'
	./make/clear-cached-chroot.sh


.PHONY: build-dev
build-dev:
	echo 'Building dev container...'
	docker build -t hpiicpc/judge-dev:latest ${CI+--cache-from hpiicpc/judge-dev:latest} docker/dev

.PHONY: start-dev
start-dev: setup-dev-data
	./make/start-dev.sh

.PHONY: stop-dev
stop-dev:
	echo 'Stopping dev container...'
	docker stop judge-dev > /dev/null
	echo 'Stopping mariadb container...'
	docker stop mariadb > /dev/null

.PHONY: setup-dev-settings
setup-dev-settings:
	docker exec judge-dev /domjudge/webapp/bin/console doctrine:fixture:load --append --group=HpiSettingsFixture
	docker exec judge-dev /domjudge/webapp/bin/console doctrine:fixture:load --append --group=HpiJudgeDevSetupFixture

.PHONY: build-prod
build-prod:
	./docker/prod/build.sh
