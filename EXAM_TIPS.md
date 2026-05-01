# CKA Exam Tips & Strategy 🎯

> Practical advice for passing the Certified Kubernetes Administrator exam on your first attempt.

---

## Exam Format Overview

| Detail | Info |
|--------|------|
| **Duration** | 2 hours |
| **Format** | Performance-based (hands-on terminal) |
| **Tasks** | 15–20 scenario-based CLI tasks |
| **Passing Score** | 66% |
| **Kubernetes Version** | v1.35 |
| **Allowed Resources** | kubernetes.io/docs, kubernetes.io/blog, helm.sh/docs |
| **Retake Policy** | 1 free retake included |
| **Results** | Emailed within 24 hours |
| **Validity** | 2 years |

---

## ✅ Official Pre-Exam Environment Checklist

> Source: [Linux Foundation Important Instructions](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad)

**System:**
- [ ] Run the [PSI system check](https://syscheck.bridge.psiexams.com/) on your exam machine
- [ ] Single monitor only — **dual monitors are NOT supported**
- [ ] Screen size ≥ 15", resolution 1080p recommended
- [ ] Do **NOT** use a virtual machine (even if compatibility check passes)
- [ ] Do **NOT** use a corporate/work machine if possible (security features disrupt PSI)
- [ ] Disable firewall / corporate proxy
- [ ] Stop antivirus scanning during exam time
- [ ] Laptop **plugged into power**

**Network:**
- [ ] Wired internet connection preferred over Wi-Fi
- [ ] Close bandwidth-heavy apps (Dropbox, BitTorrent, video calls)
- [ ] HTTPS to `*.s3.amazonaws.com` must not be blocked

**Peripherals:**
- [ ] Microphone tested and working
- [ ] Webcam moveable (for room pan during check-in)

**ID:**
- [ ] Valid **unexpired** government-issued photo ID ready (original physical document)
- [ ] Name on ID **exactly** matches your verified name in the LF portal

**Room:**
- [ ] Clutter-free desk — no paper, electronics, or other objects
- [ ] Clear walls — no printouts (paintings are OK)
- [ ] Well-lit, private, quiet space
- [ ] You must remain within the camera frame throughout

---

## ⌨️ Official Exam Technical Instructions

> Source: [Linux Foundation Important Instructions](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad)

### Critical Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Close tab **(NOT Ctrl+W — it closes Chrome!)** | `Ctrl+Alt+W` |
| Copy in Terminal | `Ctrl+Shift+C` |
| Paste in Terminal | `Ctrl+Shift+V` |
| Copy in other desktop apps | `Ctrl+C` |
| Paste in other desktop apps | `Ctrl+V` |
| Find in Firefox | `Ctrl+F` |
| Locate cursor | `Ctrl+Alt+K` |

> [!WARNING]
> The **INSERT key is prohibited** on the remote desktop. Enter vim insert mode with `i`, exit with `Esc`.

> [!WARNING]
> **Do NOT reboot the base node** (hostname `base`). It will NOT restart your exam environment.

### Node Navigation

```bash
ssh <nodename>    # SSH into a designated task node
sudo -i           # Gain elevated privileges on any node
exit              # Return to base node after task completion
```

- Nested SSH is **not** supported
- Every task runs on a specific designated host — the task infobox tells you which one
- The base node does **not** have kubectl installed

### Tools Pre-installed on All SSH Hosts

| Tool | Description |
|------|-------------|
| `kubectl` / `k` | Kubernetes CLI with bash autocompletion |
| `yq` | YAML processor |
| `curl` / `wget` | HTTP testing |
| `man` | Manual pages |

---

## Time Management Strategy

### The 2-Hour Rule

You have approximately **6–8 minutes per question** on average. Not all questions are equal — they have different point weights (usually shown in the exam).

**Recommended approach:**

1. **First pass (60 min):** Go through all questions. Solve everything you're confident about in under 5 minutes.
2. **Second pass (45 min):** Return to harder questions you flagged. Use documentation if needed.
3. **Buffer (15 min):** Final review, verify contexts, check flagged items.

### Time Signals

- If you've spent **more than 7 minutes** on a question → flag it and move on
- If a question is worth **1–2%** of the exam → don't spend more than 3 minutes
- If a question is worth **7–10%** → it deserves 10–15 minutes

### Time Allocation by Domain Weight

| Domain | Weight | Suggested Time |
|--------|--------|----------------|
| Troubleshooting | 30% | ~36 min |
| Cluster Architecture | 25% | ~30 min |
| Services & Networking | 20% | ~24 min |
| Workloads & Scheduling | 15% | ~18 min |
| Storage | 10% | ~12 min |

Cluster upgrade tasks are time-consuming — budget 12–15 min and do them only when confident.

---

## The Most Important Habit: Check Your Context

**Every single question** — before typing anything else:

```bash
kubectl config get-contexts
kubectl config use-context <required-context>
kubectl config set-context --current --namespace=<required-namespace>
```

Submitting work in the wrong cluster or namespace is one of the most common ways to lose points.

---

## Setup Your Environment (First 2 Minutes)

Run these immediately when the exam starts:

```bash
# Must-have alias
alias k=kubectl
export do="--dry-run=client -o yaml"
export now="--force --grace-period=0"

# Enable bash autocompletion
source <(kubectl completion bash)
complete -F __start_kubectl k

# Optional: set vim as default editor
export KUBE_EDITOR=vim
echo "set tabstop=2" >> ~/.vimrc
echo "set expandtab" >> ~/.vimrc
echo "set shiftwidth=2" >> ~/.vimrc
```

---

## Imperative vs Declarative: When to Use Each

### Use Imperative (fast, saves time)

```bash
k run nginx --image=nginx                          # create pod
k create deployment nginx --image=nginx            # create deployment
k expose deployment nginx --port=80                # create service
k create configmap cm --from-literal=k=v           # create configmap
k create secret generic sec --from-literal=k=v     # create secret
k create role r --verb=get --resource=pods         # create role
k scale deployment nginx --replicas=3              # scale
k set image deployment/nginx nginx=nginx:1.26      # update image
```

### Use Dry-Run to Generate YAML (then edit)

```bash
k create deployment nginx --image=nginx $do > deploy.yaml
vim deploy.yaml   # add what's needed (affinity, volumes, etc.)
k apply -f deploy.yaml
```

### Use Declarative (YAML file) When

- You need to add fields that can't be set imperatively (e.g., tolerations, affinity, volumes, probes)
- The question gives you a manifest to modify
- You need to create multiple resources at once

---

## Vim Quick Reference

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
:set paste     → Paste mode (avoids auto-indent issues when pasting YAML)
gg=G           → Auto-indent entire file (use carefully)
```

> [!TIP]
> The **INSERT key is disabled** on the exam remote desktop. Always use `i` to enter insert mode.

---

## kubectl Documentation Shortcuts

In the exam you can use `kubectl explain` — it's faster than browsing docs:

```bash
k explain pod.spec
k explain pod.spec.containers
k explain pod.spec.containers.resources
k explain networkpolicy.spec
k explain persistentvolume.spec
k explain deployment.spec.strategy
```

---

## Kubernetes Docs — Know These Pages

Bookmark these before your exam (you get one browser tab):

| Topic | URL Path |
|-------|----------|
| kubectl cheatsheet | `/docs/reference/kubectl/quick-reference/` |
| RBAC | `/docs/reference/access-authn-authz/rbac/` |
| Network Policies | `/concepts/services-networking/network-policies/` |
| PersistentVolumes | `/concepts/storage/persistent-volumes/` |
| Scheduling | `/concepts/scheduling-eviction/` |
| kubeadm install | `/setup/production-environment/tools/kubeadm/install-kubeadm/` |
| Ingress | `/concepts/services-networking/ingress/` |

---

## Common Traps & Mistakes

### 1. Wrong Namespace
Always read the question carefully. Many tasks specify a namespace. Set it:
```bash
k config set-context --current --namespace=<ns>
# or use -n flag on every command
```

### 2. Forgetting to Switch Context
Each question may require a different cluster context. **Check every time.**

### 3. Incomplete YAML Indentation
YAML is whitespace-sensitive. Always use 2 spaces, never tabs:
```bash
# In vim: gg=G to auto-indent entire file (use carefully)
```

### 4. Editing Static Pod Manifests
Static pods (in `/etc/kubernetes/manifests/`) restart automatically when you save. Wait a moment for them to reload:
```bash
watch kubectl get pods -n kube-system
```

### 5. Not Verifying Your Work
After completing each task, verify it worked:
```bash
k get pods -n <ns>
k get deployment <name> -n <ns>
k describe <resource> <name>
k auth can-i <verb> <resource> --as=<user>
```

### 6. Deleting Resources Instead of Editing
Use `kubectl edit` or `kubectl apply` — never delete unless asked. You might lose points or break dependent resources.

### 7. Forgetting `--restart=Never` for One-Off Pods
```bash
k run test-pod --image=busybox --restart=Never -- sleep 3600
```

### 8. Using Wrong API Version
Check available API versions:
```bash
k api-versions | grep <resource>
k api-resources | grep <resource>
```


## Cluster Upgrade — Exam Checklist

```bash
# 1. Drain the node first
k drain <node> --ignore-daemonsets --delete-emptydir-data

# 2. Upgrade kubeadm
apt-mark unhold kubeadm
apt-get install -y kubeadm=1.x.x-*
apt-mark hold kubeadm

# 3. Verify plan and apply
kubeadm upgrade plan
kubeadm upgrade apply v1.x.x  # control plane only

# 4. Upgrade kubelet and kubectl
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=1.x.x-* kubectl=1.x.x-*
apt-mark hold kubelet kubectl
systemctl daemon-reload
systemctl restart kubelet

# 5. Uncordon
k uncordon <node>
```

---

## Troubleshooting Checklist (30% of Exam!)

When something is broken, always follow this order:

```
1. k get <resource> -n <ns>         # Is it there? What status?
2. k describe <resource> <name>     # Events section at bottom
3. k logs <pod> [-c container]      # Application logs
4. k logs <pod> --previous          # If pod crashed
5. k get events -n <ns>             # Cluster events
6. systemctl status kubelet          # If node is NotReady
7. journalctl -u kubelet -f          # Kubelet logs on node
```

---

## Last-Minute Exam Checklist (Night Before)

- [ ] Practice switching contexts: `kubectl config use-context`
- [ ] Know how to drain/uncordon a node
- [ ] Review network policy YAML syntax
- [ ] Review PV/PVC creation and binding
- [ ] Practice creating RBAC resources imperatively
- [ ] Know how to find and fix a broken kubelet
- [ ] Get comfortable with `kubectl explain`
- [ ] Practice `--dry-run=client -o yaml` for every resource type
- [ ] Sleep well — the exam requires clear thinking

---

## Day of Exam — Official Reminders

- Launch the PSI Secure Browser **before** your exam start time to complete check-in
- Use `Ctrl+Alt+W` to close tabs, **NOT** `Ctrl+W`
- Copy/paste in the terminal uses `Ctrl+Shift+C` / `Ctrl+Shift+V`
- You can resize the Content Panel (left side) by dragging the border
- Use `Ctrl+F` in Firefox to search within the Kubernetes docs
- One extra browser tab is allowed: `kubernetes.io/docs`, `kubernetes.io/blog`, or `helm.sh/docs`
- Use font zoom (`+`/`-` on the PSI toolbar) to adjust the remote desktop text size
- Start with the highest-weighted questions you feel confident about
- Always verify your completed tasks with `kubectl get` / `kubectl describe`

> 📚 For a comprehensive exam day guide including full checklists and time strategy, see [EXAM_DAY_GUIDE.md](./EXAM_DAY_GUIDE.md).

---

*Part of the [CKA Certification Guide](./README.md)*
