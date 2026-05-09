#!/usr/bin/env bash
# Sync stack templates and configs from the repo to /srv/* without full re-init.
# Run this after changing any docker-stack.yaml.template or clickhouse config files.
set -euo pipefail

INFRA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

STACKS=(identity platform platform-frontend postgres redis clickhouse)

for stack in "${STACKS[@]}"; do
    src="${INFRA_DIR}/stacks/${stack}"
    dst="/srv/${stack}"

    if [[ -f "${src}/docker-stack.yaml.template" ]]; then
        cp "${src}/docker-stack.yaml.template" "${dst}/docker-stack.yaml.template"
        echo "[synced] ${dst}/docker-stack.yaml.template"
    fi

    if [[ -f "${src}/init.sh" ]]; then
        cp "${src}/init.sh" "${dst}/init.sh"
        chmod +x "${dst}/init.sh"
        echo "[synced] ${dst}/init.sh"
    fi

    if [[ -d "${src}/config" ]]; then
        cp -r "${src}/config" "${dst}/"
        echo "[synced] ${dst}/config/"
    fi

    if [[ -d "${src}/docker" ]]; then
        cp -r "${src}/docker" "${dst}/"
        echo "[synced] ${dst}/docker/"
    fi
done

echo ""
echo "Done. Re-deploy affected stacks to apply changes."
