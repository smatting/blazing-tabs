#!/usr/bin/env bash

set -euo pipefail

./node_modules/web-ext/bin/web-ext sign --api-key="$AMO_JWT_ISSUER" --api-secret="$AMO_JWT_SECRET" --source-dir=./src
