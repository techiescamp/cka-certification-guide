#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="$SCRIPT_DIR/settings.yaml"
CLOUD_INIT="$SCRIPT_DIR/cloud-init.yaml"

# Parse settings.yaml using only Python 3 stdlib (no pyyaml needed).
# Outputs one line per VM using tab as delimiter: "name\timage\tcpus\tmemory\tdisk"
# Tab avoids collisions with the colon in image names like "ubuntu:24.04".
parse_vms() {
    python3 - "$SETTINGS" <<'PYEOF'
import sys

image = ""
vms = []
current_vm = None

with open(sys.argv[1]) as f:
    for raw in f:
        line = raw.rstrip()
        stripped = line.lstrip()
        if line.startswith("image:"):
            image = line.split(":", 1)[1].strip().strip("'\"")
        elif stripped.startswith("- name:"):
            if current_vm:
                vms.append(current_vm)
            current_vm = {"image": image, "name": stripped.split(":", 1)[1].strip()}
        elif current_vm and stripped.startswith("cpus:"):
            current_vm["cpus"] = stripped.split(":", 1)[1].strip()
        elif current_vm and stripped.startswith("memory:"):
            current_vm["memory"] = stripped.split(":", 1)[1].strip()
        elif current_vm and stripped.startswith("disk:"):
            current_vm["disk"] = stripped.split(":", 1)[1].strip()

if current_vm:
    vms.append(current_vm)

for vm in vms:
    print("\t".join([vm["name"], vm["image"], vm["cpus"], vm["memory"], vm.get("disk", "10G")]))
PYEOF
}

vm_exists() {
    multipass list --format json | python3 -c "
import sys, json
data = json.load(sys.stdin)
names = [v['name'] for v in data.get('list', [])]
sys.exit(0 if '$1' in names else 1)
" 2>/dev/null
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

update_hosts_on_vm() {
    local vm_name="$1"
    local entries_file="$2"
    multipass transfer "$entries_file" "$vm_name:/tmp/cka-hosts"
    multipass exec "$vm_name" -- sudo bash -c '
        sed -i "/# cka-lab-start/,/# cka-lab-end/d" /etc/hosts
        cat /tmp/cka-hosts >> /etc/hosts
        rm /tmp/cka-hosts
    '
}

main() {
    echo "==> Reading settings from $SETTINGS"

    declare -a VM_NAMES=()

    while IFS=$'\t' read -r name image cpus memory disk; do
        echo ""
        echo "==> VM: $name  (image=$image cpus=$cpus memory=$memory disk=$disk)"
        if vm_exists "$name"; then
            echo "    Already exists — skipping launch."
        else
            multipass launch "$image" \
                --name "$name" \
                --cpus "$cpus" \
                --memory "$memory" \
                --disk "$disk" \
                --cloud-init "$CLOUD_INIT"
            echo "    Launched."
        fi
        VM_NAMES+=("$name")
    done < <(parse_vms)

    echo ""
    echo "==> Collecting VM IPs..."
    declare -A VM_IPS=()
    for name in "${VM_NAMES[@]}"; do
        ip=$(get_vm_ip "$name")
        VM_IPS["$name"]="$ip"
        printf "    %-15s -> %s\n" "$name" "$ip"
    done

    # Write host entries to a temp file for transfer
    local tmp_hosts
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
        update_hosts_on_vm "$name" "$tmp_hosts"
    done
    rm -f "$tmp_hosts"

    echo ""
    echo "==> Done! Summary:"
    echo ""
    for name in "${VM_NAMES[@]}"; do
        printf "    %-15s %s\n" "$name" "${VM_IPS[$name]}"
    done
    echo ""
    echo "Add these to your Mac's /etc/hosts (optional, run with sudo):"
    echo ""
    for name in "${VM_NAMES[@]}"; do
        printf "    %-15s %s\n" "${VM_IPS[$name]}" "$name"
    done
    echo ""
    echo "Connect to VMs:"
    for name in "${VM_NAMES[@]}"; do
        echo "    multipass shell $name"
    done
    echo ""
}

main
