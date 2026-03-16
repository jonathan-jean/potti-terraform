#!/usr/bin/env bash
#
# Apply Terraform configuration.
# Uses my_vars.tfvars if present. Run from the repo root.
#
# Usage:
#   ./apply.sh              # apply (will prompt for approval)
#   ./apply.sh -auto-approve
#   ./apply.sh --plan-only   # plan only, no apply
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VAR_FILE="my_vars.tfvars"
EXTRA_ARGS=()

# Parse optional flags
while [[ $# -gt 0 ]]; do
  case $1 in
    -auto-approve)
      EXTRA_ARGS+=("$1")
      shift
      ;;
    --plan-only)
      PLAN_ONLY=1
      shift
      ;;
    -var-file=*)
      VAR_FILE="${1#-var-file=}"
      shift
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

if ! command -v terraform &>/dev/null; then
  echo "Error: terraform is not in PATH." >&2
  exit 1
fi

VAR_FILE_ARG=()
if [[ -f "$VAR_FILE" ]]; then
  VAR_FILE_ARG=(-var-file="$VAR_FILE")
  echo "Using var file: $VAR_FILE"
else
  echo "Warning: $VAR_FILE not found. Using env/defaults." >&2
fi

echo "==> terraform init"
terraform init

if [[ -n "$PLAN_ONLY" ]]; then
  echo "==> terraform plan"
  terraform plan "${VAR_FILE_ARG[@]}" "${EXTRA_ARGS[@]}"
else
  echo "==> terraform apply"
  terraform apply "${VAR_FILE_ARG[@]}" "${EXTRA_ARGS[@]}"
fi
