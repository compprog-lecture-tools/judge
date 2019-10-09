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

.PHONY: clear-db clear-chroot
clear-db:
	echo 'Deleting dev database...'
	rm -rf dev-data/db

clear-chroot:
	echo 'Deleting dev chroot...'
	./make/clear-cached-chroot.sh


.PHONY: build-dev
build-dev:
	echo 'Building dev container...'
	docker build -t hpiicpc/judge-dev:latest ${CI+--cache-from hpiicpc/judge-dev:latest} docker/dev
