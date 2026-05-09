#!/usr/bin/env bash
set -euo pipefail

echo "=== Deploying infrastructure stacks ==="

deploy() {
  local stack=$1
  local name=$2
  echo ""
  echo "--- ${name} ---"
  docker stack deploy \
    --compose-file "/srv/${stack}/docker-stack.yaml.template" \
    --detach=false \
    "${name}"
}

deploy postgres   testify-postgres
deploy redis      testify-redis
deploy clickhouse testify-clickhouse

echo ""
echo "=== Done. Stack status ==="
docker stack ls
echo ""
docker service ls
