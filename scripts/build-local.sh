#!/bin/bash
# Build the container image locally using RHSM activation key secrets.
#
# One-time setup:
#   mkdir -p ~/.rhsm && chmod 700 ~/.rhsm
#   printf "YOUR_ORG_ID"       > ~/.rhsm/org  && chmod 600 ~/.rhsm/org
#   printf "YOUR_ACTIVATION_KEY" > ~/.rhsm/key && chmod 600 ~/.rhsm/key
# Org ID and activation keys: https://console.redhat.com/insights/connector/activation-keys

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

RHSM_ORG_FILE="${HOME}/.rhsm/org"
RHSM_KEY_FILE="${HOME}/.rhsm/key"

if [[ ! -f "$RHSM_ORG_FILE" ]] || [[ ! -f "$RHSM_KEY_FILE" ]]; then
  echo "ERROR: RHSM credentials not found."
  echo "Create them with:"
  echo "  mkdir -p ~/.rhsm && chmod 700 ~/.rhsm"
  echo "  printf 'YOUR_ORG_ID' > ~/.rhsm/org && chmod 600 ~/.rhsm/org"
  echo "  printf 'YOUR_ACTIVATION_KEY' > ~/.rhsm/key && chmod 600 ~/.rhsm/key"
  exit 1
fi

TAG="${1:-localhost/notebooklm-mcp:dev}"

echo "Building $TAG ..."
podman build \
  --secret id=rhsm_org,src="$RHSM_ORG_FILE" \
  --secret id=rhsm_key,src="$RHSM_KEY_FILE" \
  -t "$TAG" \
  "$REPO_ROOT"
