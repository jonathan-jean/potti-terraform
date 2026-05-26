#!/usr/bin/env bash
#
# Apply CORS to the potti-production bucket on OVH Object Storage.
# Prompts for AWS-compatible credentials (interactive); they are only used for
# this command and are not written to disk or left exported in your shell.
#
# Usage:
#   ./put-bucket-cors-interactive.sh
#
# Optional environment overrides:
#   BUCKET, ENDPOINT_URL, CORS_FILE, AWS_REGION
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BUCKET="${BUCKET:-potti-production}"
ENDPOINT_URL="${ENDPOINT_URL:-https://s3.eu-west-par.io.cloud.ovh.net}"
CORS_FILE="${CORS_FILE:-$SCRIPT_DIR/cors.json}"
# OVH PAR; override if your bucket lives elsewhere
AWS_REGION="${AWS_REGION:-eu-west-par}"

if ! command -v aws &>/dev/null; then
  echo "Error: aws CLI is not in PATH." >&2
  exit 1
fi

if [[ ! -f "$CORS_FILE" ]]; then
  echo "Error: CORS file not found: $CORS_FILE" >&2
  exit 1
fi

echo "OVH S3-compatible API — bucket: $BUCKET"
echo "Endpoint: $ENDPOINT_URL"
echo "CORS file: $CORS_FILE"
echo ""
echo "Enter credentials (input is hidden for the secret key)."
read -r -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -r -s -p "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo ""
read -r -p "Session token (optional, for temporary creds; leave empty): " AWS_SESSION_TOKEN
echo ""

if [[ -z "${AWS_ACCESS_KEY_ID}" || -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
  echo "Error: Access Key ID and Secret Access Key are required." >&2
  exit 1
fi

ENV_ARGS=(
  AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
  AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
)
if [[ -n "${AWS_SESSION_TOKEN}" ]]; then
  ENV_ARGS+=(AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN")
fi

env "${ENV_ARGS[@]}" aws s3api put-bucket-cors \
  --bucket "$BUCKET" \
  --cors-configuration "file://$CORS_FILE" \
  --endpoint-url "$ENDPOINT_URL" \

echo "Done: CORS updated for s3://$BUCKET"
