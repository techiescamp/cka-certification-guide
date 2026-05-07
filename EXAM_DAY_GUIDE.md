# CKA Exam Day Guide

> A concise, printable-style reference to use the day before and day of your CKA exam.
> All information sourced from official Linux Foundation documentation.

---

## ⏰ Quick Stats (CKA v1.35)

| Item | Detail |
|------|--------|
| **Duration** | 2 hours |
| **Tasks** | 16 performance-based |
| **Passing Score** | 66% |
| **Kubernetes Version** | v1.35 |
| **Results** | Emailed within 24 hours |
| **Validity** | 2 years |
| **Retake** | 1 free retake included |

---

## ✅ Pre-Exam Environment Checklist

Run through this the day before your exam:

- [ ] Run [PSI system check](https://syscheck.bridge.psiexams.com/) on your exam machine
- [ ] Single monitor only — dual monitors are **NOT** supported
- [ ] Screen size ≥ 15", resolution 1080p recommended
- [ ] **Wired internet connection** preferred over Wi-Fi
- [ ] Close bandwidth-heavy apps (Dropbox, BitTorrent, video calls)
- [ ] Disable firewall or corporate proxy (can block PSI Secure Browser)
- [ ] Stop antivirus scanning during exam time
- [ ] Laptop **plugged into power** (battery must not die mid-exam)
- [ ] Do **NOT** use a corporate machine if possible (security policies can disrupt PSI)
- [ ] Do **NOT** use a virtual machine to take the exam
- [ ] Test microphone — must work before exam starts
- [ ] Webcam must be moveable (for room pan during check-in)
- [ ] Valid government-issued photo ID ready (unexpired, original, physical)
- [ ] Name on ID must **exactly** match your verified name on the LF portal

### Room Requirements
- [ ] Clutter-free desk — no paper, electronics, or other objects
- [ ] Clear walls — no paper/printouts (paintings are OK)
- [ ] Well-lit room — proctor must see your face, hands, and workspace
- [ ] Private, quiet space (no coffee shops, open offices, etc.)
- [ ] You must stay within the camera frame throughout

---

## 🖥️ Exam Interface Quick Reference

### Keyboard Shortcuts (Remote Desktop)

| Action | Shortcut |
|--------|----------|
| **Close tab (Chrome)** | Use `Ctrl+Alt+W` (**NOT** `Ctrl+W`) |
| **Copy** (Terminal) | `Ctrl+Shift+C` |
| **Paste** (Terminal) | `Ctrl+Shift+V` |
| **Copy** (other apps on remote desktop) | `Ctrl+C` |
| **Paste** (other apps on remote desktop) | `Ctrl+V` |
| **Find in Firefox** | `Ctrl+F` |
| **Locate cursor** | `Ctrl+Alt+K` |
| **Vim INSERT mode** | `i` (INSERT key is disabled) |
| **Exit INSERT mode (Vim)** | `Esc` |

> [!WARNING]
> The **INSERT key is prohibited** on the remote desktop. Always use `i` to enter insert mode in vim, and `Esc` to exit.

> [!WARNING]
> **Do NOT reboot the base node** (`hostname: base`). Rebooting it will NOT restart your exam environment.

### Navigating Nodes

```bash
# You work from the base system — SSH into designated hosts
ssh <nodename>

# Get elevated privileges on any node
sudo -i

# Exit SSH session to return to base
exit
```

> [!IMPORTANT]
> Each exam task tells you which node to work on. Complete the task on that node, then `exit` back to base. **Nested SSH is not supported.**

### Pre-installed Tools (on all SSH hosts)

| Tool | Description |
|------|-------------|
| `kubectl` | Kubernetes CLI |
| `k` | Alias for `kubectl` (with bash autocompletion) |
| `yq` | YAML processor |
| `curl` | HTTP requests |
| `wget` | HTTP downloads |
| `man` | Manual pages |

> [!NOTE]
> The **base node** does NOT have kubectl or these tools. All work must be done on designated SSH hosts.

### Allowed Resources During Exam

You may open **one additional browser tab** pointing to:
- `https://kubernetes.io/docs`
- `https://kubernetes.io/blog`
- `https://helm.sh/docs`

No other websites, notes, or books are allowed.

---

## ⚡ First 5 Minutes of the Exam

Run these immediately after logging in — do this on **every node** you SSH into:

```bash
# 1. Confirm alias and autocompletion work (pre-configured on exam nodes)
k version --short

# 2. Set up speed shortcuts (if not already set)
alias k=kubectl
export do="--dry-run=client -o yaml"
export now="--force --grace-period=0"

# 3. Enable bash completion
source <(kubectl completion bash)
complete -F __start_kubectl k

# 4. Configure vim for YAML editing
echo "set tabstop=2" >> ~/.vimrc
echo "set expandtab" >> ~/.vimrc
echo "set shiftwidth=2" >> ~/.vimrc
export KUBE_EDITOR=vim

# 5. Check current context before every task
k config get-contexts
k config current-context
```

---

## 🕐 Time Management Strategy

The exam is **2 hours** for 15–20 tasks.

| Strategy | Detail |
|----------|--------|
| **Budget per task** | ~6–8 minutes on average |
| **Skip and return** | Flag hard questions, return after easier ones |
| **Partial credit** | Exists — incomplete answers still score points |
| **High-weight tasks** | Do these first if confident |
| **Cluster upgrade** | Time-consuming — plan carefully |
| **Verify your work** | Always run `kubectl get`/`describe` to confirm |

### Time allocation by domain weight

| Domain | Weight | Suggested Time |
|--------|--------|---------------|
| Troubleshooting | 30% | ~36 min |
| Cluster Architecture | 25% | ~30 min |
| Services & Networking | 20% | ~24 min |
| Workloads & Scheduling | 15% | ~18 min |
| Storage | 10% | ~12 min |

**3-pass approach:**
1. **First pass (60 min):** Solve everything under 5 min — skip the rest
2. **Second pass (45 min):** Return to flagged questions, use docs
3. **Buffer (15 min):** Final verification pass

---

## ⚙️ Imperative Commands Quick Reference

```bash
# Pods
k run nginx --image=nginx
k run busybox --image=busybox --restart=Never -- sleep 3600

# Deployments
k create deploy app --image=nginx --replicas=3

# Services
k expose deploy app --port=80 --target-port=8080
k create svc clusterip my-svc --tcp=80:8080

# ConfigMaps & Secrets
k create configmap cm --from-literal=key=value
k create secret generic sec --from-literal=key=value --from-file=./file

# RBAC
k create role r --verb=get,list --resource=pods
k create rolebinding rb --role=r --user=username
k create clusterrole cr --verb=get --resource=pods
k create clusterrolebinding crb --clusterrole=cr --user=username

# Scale / Image update
k scale deploy app --replicas=5
k set image deploy/app nginx=nginx:1.26

# Generate YAML without applying
k run nginx --image=nginx $do > pod.yaml
k create deploy app --image=nginx $do > deploy.yaml
```

---

## 🔑 Essential kubectl One-Liners for Speed

```bash
# Delete fast (no grace period)
k delete pod my-pod $now

# Switch namespace quickly
k config set-context --current --namespace=my-namespace

# Switch cluster context (required per task!)
k config use-context <context-name>

# Get all resources in a namespace
k get all -n my-namespace

# Check events (great for debugging)
k get events --sort-by='.lastTimestamp' -n my-namespace

# Explain resource fields without docs
k explain pod.spec.containers.livenessProbe
k explain deployment.spec.strategy
k explain networkpolicy.spec

# Check RBAC
k auth can-i create pods --as=<user> -n <ns>

# Check available API versions for a resource
k api-resources | grep ingress
k api-versions | grep networking
```

---

## 🛠️ Vim Quick Reference (for the exam)

```
i          → Enter INSERT mode
Esc        → Return to COMMAND mode
:wq        → Save and quit
:q!        → Quit without saving
dd         → Delete current line
yy         → Copy (yank) current line
p          → Paste after cursor
u          → Undo
gg         → Go to top of file
G          → Go to bottom of file
/pattern   → Search forward
n          → Next search result
:%s/old/new/g  → Replace all occurrences
:set number    → Show line numbers
:set paste     → Paste mode (avoids auto-indent issues)
gg=G           → Auto-indent entire file (use carefully)
```

---

## 🔧 Troubleshooting Quick Flow (30% of Exam)

When something is broken, follow this order every time:

```bash
# Step 1 — Is the resource there? What state?
k get <resource> -n <ns>

# Step 2 — What does Kubernetes think is wrong?
k describe <resource> <name> -n <ns>   # check Events at bottom

# Step 3 — What does the application say?
k logs <pod> -n <ns>
k logs <pod> -n <ns> --previous        # if pod keeps crashing

# Step 4 — Cluster-wide events
k get events -n <ns> --sort-by='.lastTimestamp'

# Step 5 — Node/kubelet issues (if node is NotReady)
ssh <node>
sudo -i
systemctl status kubelet
journalctl -u kubelet -f

# Step 6 — Static pod issues (control plane components)
ls /etc/kubernetes/manifests/
cat /etc/kubernetes/manifests/kube-apiserver.yaml
```

---

## 🔼 Cluster Upgrade Quick Checklist

```bash
# 1. Drain the control plane node
k drain <node> --ignore-daemonsets --delete-emptydir-data

# 2. Upgrade kubeadm
apt-mark unhold kubeadm
apt-get install -y kubeadm=1.x.x-*
apt-mark hold kubeadm

# 3. Plan and apply
kubeadm upgrade plan
kubeadm upgrade apply v1.x.x    # control plane only

# 4. Upgrade kubelet + kubectl
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=1.x.x-* kubectl=1.x.x-*
apt-mark hold kubelet kubectl
systemctl daemon-reload
systemctl restart kubelet

# 5. Uncordon
k uncordon <node>


# For each worker node (repeat per node):
k drain <worker-node> --ignore-daemonsets --delete-emptydir-data
# SSH into the worker node, then:
ssh <worker-node>
sudo -i
apt-mark unhold kubeadm kubelet kubectl
apt-get install -y kubeadm=1.x.x-* kubelet=1.x.x-* kubectl=1.x.x-*
apt-mark hold kubeadm kubelet kubectl
kubeadm upgrade node
systemctl daemon-reload && systemctl restart kubelet
exit
# Back on control plane:
k uncordon <worker-node>
```

---

## 📚 Kubernetes Docs Bookmarks

One browser tab allowed. Know these paths:

| Topic | URL Path |
|-------|----------|
| kubectl cheatsheet | `/docs/reference/kubectl/quick-reference/` |
| RBAC | `/docs/reference/access-authn-authz/rbac/` |
| Network Policies | `/concepts/services-networking/network-policies/` |
| PersistentVolumes | `/concepts/storage/persistent-volumes/` |
| Scheduling | `/concepts/scheduling-eviction/` |
| kubeadm install | `/setup/production-environment/tools/kubeadm/install-kubeadm/` |
| Ingress | `/concepts/services-networking/ingress/` |

Use `Ctrl+F` in Firefox to search within any docs page.

---

## 🧠 Common Exam Mistakes to Avoid

| Mistake | Prevention |
|---------|-----------|
| Wrong namespace | Always check task context; use `-n <namespace>` |
| Wrong cluster context | Run `k config use-context <ctx>` before each task |
| Forgetting `sudo -i` | Always escalate on worker nodes |
| Not verifying work | After every task, run `k get`/`describe` to confirm |
| Editing wrong file | Double-check paths: `/etc/kubernetes/manifests/` |
| Accidentally closing tab | Use `Ctrl+Alt+W` NOT `Ctrl+W` |
| Running out of time | Skip, flag, come back — partial credit beats nothing |
| Tabs in YAML | Always use 2 spaces, never tabs |
| Forgetting `--restart=Never` | Required for one-off pods: `k run test --image=busybox --restart=Never` |

---

## 📞 Support

If you have issues during check-in or the exam:
- Login to [trainingsupport.linuxfoundation.org](https://trainingsupport.linuxfoundation.org) with your LF account
- The proctor can assist with technical issues during check-in

---

> 📚 Related: [SYLLABUS.md](./SYLLABUS.md) | [EXAM_TIPS.md](./EXAM_TIPS.md) | [CHEATSHEET.md](./CHEATSHEET.md) | [FAQ.md](./FAQ.md)
