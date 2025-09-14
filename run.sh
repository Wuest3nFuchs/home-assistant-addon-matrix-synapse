#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="/config"
DATA_DIR="/data"
SERVER_NAME="${SERVER_NAME:-$(jq -r '.server_name // "example.com"' ${CONFIG_DIR}/addon.json 2>/dev/null || echo "example.com")}"
HTTP_PORT="${HTTP_PORT:-8008}"
BIND_ADDRESS="${BIND_ADDRESS:-0.0.0.0}"
ENABLE_REGISTRATION="${ENABLE_REGISTRATION:-false}"
REG_SECRET="${REGISTRATION_SHARED_SECRET:-}"

if [ ! -f "${CONFIG_DIR}/homeserver.yaml" ]; then
  echo "Generating Synapse config for ${SERVER_NAME}..."
  python -m synapse.app.homeserver \
    --server-name "${SERVER_NAME}" \
    --config-path "${CONFIG_DIR}/homeserver.yaml" \
    --generate-config \
    --report-stats "${REPORT_STATS:-false}"
  chown synapse:synapse "${CONFIG_DIR}/homeserver.yaml"
fi

if command -v python >/dev/null 2>&1; then
  python - <<'PY'
import os, json, yaml, sys
cfg_path = "/config/homeserver.yaml"
addon_path = "/config/addon.json"
if os.path.exists(addon_path) and os.path.exists(cfg_path):
    addon = json.load(open(addon_path))
    overrides = addon.get("options", {}).get("synapse_config_overrides", {})
    if overrides:
        cfg = yaml.safe_load(open(cfg_path))
        cfg.update(overrides)
        yaml.safe_dump(cfg, open(cfg_path, "w"))
PY
fi

if [ "${ENABLE_REGISTRATION}" = "true" ] && [ -n "${REG_SECRET}" ]; then
  if ! grep -q "registration_shared_secret" "${CONFIG_DIR}/homeserver.yaml"; then
    echo "registration_shared_secret: ${REG_SECRET}" >> "${CONFIG_DIR}/homeserver.yaml"
  fi
fi

exec python -m synapse.app.homeserver \
  --config-path "${CONFIG_DIR}/homeserver.yaml" \
  --generate-keys-if-missing \
  --prometheus-bind "${BIND_ADDRESS}:${HTTP_PORT}"

