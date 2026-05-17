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

while read -r name; do
    echo "--- $name"
    multipass transfer "$COMMON" "$name:/tmp/common.sh"
    multipass exec "$name" -- sudo bash /tmp/common.sh
    echo "--- $name done"
    echo ""
done < <(parse_vm_names)

echo "==> All nodes provisioned."
