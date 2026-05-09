#!/usr/bin/env bash
set -euo pipefail

INFRA=/home/sultonxon/testify-infra

for stack in identity platform platform-frontend postgres redis clickhouse; do
  mkdir -p /srv/${stack}
  cp "${INFRA}/stacks/${stack}/docker-stack.yaml.template" "/srv/${stack}/"
  echo "[copied] /srv/${stack}/docker-stack.yaml.template"
done

cp "${INFRA}/stacks/postgres/init.sh" /srv/postgres/init.sh
chmod +x /srv/postgres/init.sh

cp -r "${INFRA}/stacks/clickhouse/docker" /srv/clickhouse/docker
chmod +x /srv/clickhouse/docker/clickhouse/local/init-db.sh

cp "${INFRA}/envs/staging/identity.env"           /srv/identity/identity.env
cp "${INFRA}/envs/staging/platform.env"           /srv/platform/platform.env
cp "${INFRA}/envs/staging/platform-frontend.env"  /srv/platform-frontend/platform-frontend.env
cp "${INFRA}/envs/staging/postgres.env"           /srv/postgres/postgres.env
cp "${INFRA}/envs/staging/redis.env"              /srv/redis/redis.env
cp "${INFRA}/envs/staging/clickhouse.env"         /srv/clickhouse/clickhouse.env

echo ""
echo "=== /srv layout ==="
find /srv -maxdepth 2 | sort
