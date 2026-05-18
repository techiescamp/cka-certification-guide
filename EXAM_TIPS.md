# CKA Exam Tips 2026 — Strategy, Time Management & Common Traps to Avoid 🎯

> Practical advice for passing the Certified Kubernetes Administrator exam (Kubernetes v1.35) on your first attempt.

**Q: What is the most important thing to do before every CKA exam question?**

A: Check your cluster context and namespace. Run `kubectl config use-context <ctx>` and `kubectl config set-context --current --namespace=<ns>`. Wrong context is the #1 reason candidates lose points on correct work.

## Step-by-Step Exam Approach

1. **Read the full question** before typing anything — note the namespace, cluster context, and resource names
2. **Switch context** — `kubectl config use-context <required-context>`
3. **Set namespace** — `kubectl config set-context --current --namespace=<ns>` or use `-n <ns>` on every command
4. **Use imperative commands first** — faster than writing YAML from scratch
5. **Dry-run to YAML if complex** — `kubectl create ... --dry-run=client -o yaml > file.yaml`
6. **Verify your work** — `kubectl get` / `kubectl describe` after every task
7. **Flag and skip** if stuck after 3 minutes — return in the second pass

---

## ✅ Pre-Exam Checklist & Technical Setup

For the full environment checklist, keyboard shortcuts, node navigation, and pre-installed tools reference, see:

📅 **[Exam Day Guide — Pre-Exam Checklist](./EXAM_DAY_GUIDE.md#-pre-exam-environment-checklist)**

---

## Time Management Strategy

### The 2-Hour Rule

You have approximately **6–8 minutes per question** on average. Not all questions are equal — they have different point weights (usually shown in the exam).

For the 3-pass strategy and domain time allocation table, see: 📅 **[Exam Day Guide — Time Management](./EXAM_DAY_GUIDE.md#-time-management-strategy)**

### Time Signals

- If you've spent **more than 7 minutes** on a question → flag it and move on
- If a question is worth **1–2%** of the exam → don't spend more than 3 minutes
- If a question is worth **7–10%** → it deserves 10–15 minutes

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

Run these on every node immediately when the exam starts. See full setup commands: 📅 **[Exam Day Guide — First 5 Minutes](./EXAM_DAY_GUIDE.md#️-first-5-minutes-of-the-exam)**

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

See the full vim cheatsheet: 📅 **[Exam Day Guide — Vim Reference](./EXAM_DAY_GUIDE.md#️-vim-quick-reference-for-the-exam)**

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

See the full docs bookmark list: 📅 **[Exam Day Guide — Docs Bookmarks](./EXAM_DAY_GUIDE.md#-kubernetes-docs-bookmarks)**

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

See the full step-by-step upgrade procedure: 📅 **[Exam Day Guide — Cluster Upgrade](./EXAM_DAY_GUIDE.md#-cluster-upgrade-quick-checklist)**

---

## Troubleshooting Checklist (30% of Exam!)

For the full troubleshooting flow and debug playbooks, see:

- 📅 **[Exam Day Guide — Troubleshooting Quick Flow](./EXAM_DAY_GUIDE.md#-troubleshooting-quick-flow-30-of-exam)**
- 🔧 **[Troubleshooting Guide — Full Playbooks](./TROUBLESHOOTING_GUIDE.md)**

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
