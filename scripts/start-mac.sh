#!/usr/bin/env bash
set -euo pipefail

APP_NAME="pm-app"
IMAGE_NAME="pm-app"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

docker build -t "$IMAGE_NAME" "$ROOT_DIR"

docker rm -f "$APP_NAME" >/dev/null 2>&1 || true

ENV_FILE_ARG=""
if [ -f "$ROOT_DIR/.env" ]; then
  ENV_FILE_ARG="--env-file $ROOT_DIR/.env"
fi

docker run -d --name "$APP_NAME" $ENV_FILE_ARG -p 8000:8000 "$IMAGE_NAME"
echo "App running at http://localhost:8000"
