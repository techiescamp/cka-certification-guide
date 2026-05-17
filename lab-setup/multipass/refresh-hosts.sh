#!/usr/bin/env bash
# Run this after "multipass start" to re-sync /etc/hosts on all VMs,
# since DHCP may assign new IPs after a restart.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="$SCRIPT_DIR/settings.yaml"

parse_vm_names() {
    python3 - "$SETTINGS" <<'PYEOF'
import sys

with open(sys.argv[1]) as f:
    for raw in f:
        stripped = raw.lstrip().rstrip()
        if stripped.startswith("- name:"):
            print(stripped.split(":", 1)[1].strip())
PYEOF
}

get_vm_ip() {
    multipass info "$1" --format json 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for _, d in data.get('info', {}).items():
    addrs = d.get('ipv4', [])
    if addrs:
        print(addrs[0])
        break
"
}

mapfile -t VM_NAMES < <(parse_vm_names)

echo "==> Collecting current IPs..."
declare -A VM_IPS=()
for name in "${VM_NAMES[@]}"; do
    ip=$(get_vm_ip "$name")
    VM_IPS["$name"]="$ip"
    printf "    %-15s -> %s\n" "$name" "$ip"
done

tmp_hosts=$(mktemp)
{
    echo "# cka-lab-start"
    for name in "${VM_NAMES[@]}"; do
        printf "%-15s %s\n" "${VM_IPS[$name]}" "$name"
    done
    echo "# cka-lab-end"
} > "$tmp_hosts"

echo ""
echo "==> Updating /etc/hosts on all VMs..."
for name in "${VM_NAMES[@]}"; do
    echo "    $name"
    multipass transfer "$tmp_hosts" "$name:/tmp/cka-hosts"
    multipass exec "$name" -- sudo bash -c '
        sed -i "/# cka-lab-start/,/# cka-lab-end/d" /etc/hosts
        cat /tmp/cka-hosts >> /etc/hosts
        rm /tmp/cka-hosts
    '
done
rm -f "$tmp_hosts"

echo ""
echo "==> Done. Current mappings:"
for name in "${VM_NAMES[@]}"; do
    printf "    %-15s %s\n" "${VM_IPS[$name]}" "$name"
done
