#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="$SCRIPT_DIR/settings.yaml"
COMMON="$SCRIPT_DIR/common.sh"

parse_vm_names() {
    python3 - "$SETTINGS" <<'PYEOF'
import sys

with open(sys.argv[1]) as f:
    for raw in f:
        stripped = raw.strip()
        if stripped.startswith("- name:"):
            print(stripped.split(":", 1)[1].strip())
PYEOF
}

echo "==> Provisioning VMs with $(basename "$COMMON")"
echo ""

failed=()

while read -r name; do
    echo "--- $name"
    if multipass transfer "$COMMON" "$name:/tmp/common.sh" &&
        multipass exec "$name" -- sudo bash /tmp/common.sh < /dev/null; then
        echo "--- $name done"
    else
        echo "--- $name FAILED"
        failed+=("$name")
    fi
    echo ""
done < <(parse_vm_names)

if [ ${#failed[@]} -gt 0 ]; then
    echo "==> Provisioning failed on: ${failed[*]}. Fix the issue and re-run ./provision.sh"
    exit 1
fi

echo "==> All nodes provisioned."
