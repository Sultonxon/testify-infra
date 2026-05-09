#!/usr/bin/env bash
set -euo pipefail

INFRA="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for stack in identity platform platform-frontend postgres redis clickhouse; do
  mkdir -p /srv/${stack}
  cp "${INFRA}/stacks/${stack}/docker-stack.yaml.template" "/srv/${stack}/"
  echo "[copied] /srv/${stack}/docker-stack.yaml.template"
done

cp "${INFRA}/stacks/postgres/init.sh" /srv/postgres/init.sh
chmod +x /srv/postgres/init.sh

cp -r "${INFRA}/stacks/clickhouse/docker" /srv/clickhouse/docker
chmod +x /srv/clickhouse/docker/clickhouse/local/init-db.sh

copy_env() {
  local name=$1 dst=$2
  local src_env="${INFRA}/envs/staging/${name}.env"
  local src_tmpl="${INFRA}/envs/staging/${name}.env.template"
  local target="${dst}/${name}.env"

  if [[ -f "${src_env}" ]]; then
    cp "${src_env}" "${target}"
    echo "[copied]  ${target}  (from .env)"
  elif [[ -f "${src_tmpl}" ]]; then
    cp "${src_tmpl}" "${target}"
    echo "[template] ${target}  ← fill in placeholders before deploying"
  else
    echo "[missing] no env file for ${name}"
  fi
}

copy_env identity          /srv/identity
copy_env platform          /srv/platform
copy_env platform-frontend /srv/platform-frontend
copy_env postgres          /srv/postgres
copy_env redis             /srv/redis
copy_env clickhouse        /srv/clickhouse

echo ""
echo "=== /srv layout ==="
find /srv -maxdepth 2 | sort
