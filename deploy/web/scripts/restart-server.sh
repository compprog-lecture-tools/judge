#!/usr/bin/env bash
docker exec judge-web supervisorctl restart php nginx
