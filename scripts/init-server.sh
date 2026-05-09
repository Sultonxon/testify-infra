#!/usr/bin/env bash
# Run once on a fresh server to prepare /srv/* directories, overlay network, and nginx symlinks.
set -euo pipefail

INFRA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Testify Infrastructure — Server Init ==="
echo "Infra repo: $INFRA_DIR"
echo ""

# --- Docker overlay network ---
if docker network ls --filter name=testify-net --format '{{.Name}}' | grep -q '^testify-net$'; then
    echo "[skip] Overlay network testify-net already exists"
else
    docker network create --driver overlay --attachable testify-net
    echo "[done] Created overlay network: testify-net"
fi

# --- /srv/* directories and stack templates ---
STACKS=(identity platform platform-frontend postgres redis clickhouse)

for stack in "${STACKS[@]}"; do
    dir="/srv/$stack"
    mkdir -p "$dir"

    src="$INFRA_DIR/stacks/$stack"

    if [[ -f "$src/docker-stack.yaml.template" ]]; then
        cp "$src/docker-stack.yaml.template" "$dir/docker-stack.yaml.template"
        echo "[done] $dir/docker-stack.yaml.template"
    fi

    if [[ -f "$src/init.sh" ]]; then
        cp "$src/init.sh" "$dir/init.sh"
        chmod +x "$dir/init.sh"
        echo "[done] $dir/init.sh"
    fi

    if [[ -d "$src/config" ]]; then
        cp -r "$src/config" "$dir/"
        echo "[done] $dir/config/"
    fi
done

# --- Nginx ---
mkdir -p /etc/nginx/certs
mkdir -p /etc/nginx/sites-enabled

for conf in "$INFRA_DIR"/nginx/sites-available/*.conf; do
    name=$(basename "$conf")
    target="/etc/nginx/sites-enabled/$name"
    ln -sf "$conf" "$target"
    echo "[done] Nginx site enabled: $name"
done

echo ""
echo "=== Next steps ==="
echo ""
echo "1. Place Cloudflare origin certificate:"
echo "     /etc/nginx/certs/cloudflare-origin.crt"
echo "     /etc/nginx/certs/cloudflare-origin.key"
echo ""
echo "2. Copy env files to each stack directory (fill in REPLACE_ME values first):"
for stack in "${STACKS[@]}"; do
    case "$stack" in
        platform-frontend) envname="platform-frontend" ;;
        *) envname="$stack" ;;
    esac
    echo "     cp envs/staging/${envname}.env /srv/${stack}/${envname}.env"
done
echo "     cp stacks/runner/.env.template stacks/runner/.env  # then fill in PAT and DOCKER_GID"
echo ""
echo "3. Test and reload nginx:"
echo "     nginx -t && systemctl reload nginx"
echo ""
echo "4. Start infrastructure stacks:"
echo "     docker stack deploy --compose-file /srv/postgres/docker-stack.yaml.template  testify-postgres"
echo "     docker stack deploy --compose-file /srv/redis/docker-stack.yaml.template     testify-redis"
echo "     docker stack deploy --compose-file /srv/clickhouse/docker-stack.yaml.template testify-clickhouse"
echo ""
echo "5. App stacks are deployed automatically by GitHub Actions after each build."
echo "   To deploy manually (replace VERSION with the actual image tag):"
echo "     VERSION=1.0.0 sed \"s/{version}/\$VERSION/g\" /srv/identity/docker-stack.yaml.template > /srv/identity/docker-stack.yaml"
echo "     docker stack deploy --compose-file /srv/identity/docker-stack.yaml --with-registry-auth testify-identity"
echo ""
echo "6. Start GitHub runners:"
echo "     cd stacks/runner && docker compose up -d"
