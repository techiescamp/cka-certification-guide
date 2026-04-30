# CKA Exam Day Guide

> A concise, printable-style reference to use the day before and day of your CKA exam.
> All information sourced from official Linux Foundation documentation.

---

## ⏰ Quick Stats (CKA v1.35)

| Item | Detail |
|------|--------|
| **Duration** | 2 hours |
| **Tasks** | 15–20 performance-based |
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

Run these immediately after logging in to any node:

```bash
# 1. Verify kubectl alias works
k version --short

# 2. Check which context you're in
k config get-contexts
k config current-context

# 3. Set namespace (if task specifies one)
k config set-context --current --namespace=<namespace>

# 4. Enable bash completion (if not already active)
source <(kubectl completion bash)
complete -F __start_kubectl k
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
| **etcd/cluster upgrade** | Time-consuming — plan carefully |
| **Verify your work** | Always run `kubectl get`/`describe` to confirm |

### Time allocation by domain weight

| Domain | Weight | Suggested Time |
|--------|--------|---------------|
| Troubleshooting | 30% | ~36 min |
| Cluster Architecture | 25% | ~30 min |
| Services & Networking | 20% | ~24 min |
| Workloads & Scheduling | 15% | ~18 min |
| Storage | 10% | ~12 min |

---

## 🔑 Essential kubectl One-Liners for Speed

```bash
# Generate YAML without applying (fastest way to get a template)
k run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
k create deploy app --image=nginx --replicas=3 --dry-run=client -o yaml > deploy.yaml
k create svc clusterip my-svc --tcp=80:8080 --dry-run=client -o yaml > svc.yaml

# Delete fast (no grace period)
k delete pod my-pod --grace-period=0 --force

# Switch namespace quickly
k config set-context --current --namespace=my-namespace

# Get all resources in a namespace
k get all -n my-namespace

# Check events (great for debugging)
k get events --sort-by='.lastTimestamp' -n my-namespace

# Explain resource fields without docs
k explain pod.spec.containers.livenessProbe
k explain deployment.spec.strategy
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
```

---

## 🧠 Common Exam Mistakes to Avoid

| Mistake | Prevention |
|---------|-----------|
| Wrong namespace | Always check task context; use `-n <namespace>` |
| Wrong cluster context | Run `k config current-context` before each task |
| Forgetting `sudo -i` | Always escalate on worker nodes |
| Not verifying work | After every task, run `k get`/`describe` to confirm |
| Editing wrong file | Double-check paths: `/etc/kubernetes/manifests/` |
| etcd wrong flags | Always specify `--endpoints`, `--cacert`, `--cert`, `--key` |
| Accidentally closing tab | Use `Ctrl+Alt+W` NOT `Ctrl+W` |
| Running out of time | Skip, flag, come back — partial credit is better than nothing |

---

## 📞 Support

If you have issues during check-in or the exam:
- Login to [trainingsupport.linuxfoundation.org](https://trainingsupport.linuxfoundation.org) with your LF account
- The proctor can assist with technical issues during check-in

---

> 📚 Related: [SYLLABUS.md](./SYLLABUS.md) | [EXAM_TIPS.md](./EXAM_TIPS.md) | [CHEATSHEET.md](./CHEATSHEET.md) | [FAQ.md](./FAQ.md)
