# CKA Exam FAQ 2026 — Cost, Format, Passing Score, Retake Policy & Requirements

> Official answers sourced from the [Linux Foundation CKA/CKAD/CKS FAQ](https://docs.linuxfoundation.org/tc-docs/certification/faq-cka-ckad-cks).
> Last verified: April 2026.

**Q: How much does the CKA exam cost?**
A: $395 USD. Use coupon code **35KUBECT** at [kube.promo/cka](https://kube.promo/cka) for a discount.

**Q: What is the passing score for the CKA exam?**
A: 66%. Partial credit applies — you earn points for incomplete but partially correct answers.

**Q: Is there a free retake for the CKA exam?**
A: Yes. One free retake is included with every purchase. It must be scheduled within 12 months of your original purchase date.

**Q: How is the CKA exam scored?**
A: Auto-scored immediately on submission. Results are emailed within 24 hours. Each task has a point value; partial credit is awarded for partially correct solutions.

---

## 📋 Table of Contents

1. [What is the CKA Certification?](#what-is-the-cka-certification)
2. [How much does the exam cost?](#how-much-does-the-exam-cost)
3. [How long is the exam?](#how-long-is-the-exam)
4. [What score is needed to pass?](#what-score-is-needed-to-pass)
5. [How is the exam scored?](#how-is-the-exam-scored)
6. [What Kubernetes version is used?](#what-kubernetes-version-is-used)
7. [What resources are allowed during the exam?](#what-resources-are-allowed-during-the-exam)
8. [How is the exam proctored?](#how-is-the-exam-proctored)
9. [What are the system requirements?](#what-are-the-system-requirements)
10. [What are the testing environment requirements?](#what-are-the-testing-environment-requirements)
11. [What ID is required?](#what-id-is-required)
12. [What languages is the exam available in?](#what-languages-is-the-exam-available-in)
13. [How long is the certification valid?](#how-long-is-the-certification-valid)
14. [How do I renew my certification?](#how-do-i-renew-my-certification)
15. [Where can I find practice questions / a simulator?](#where-can-i-find-practice-questions--a-simulator)
16. [Is there training to prepare for the exam?](#is-there-training-to-prepare-for-the-exam)
17. [Can I retake the exam if I fail?](#can-i-retake-the-exam-if-i-fail)
18. [What is the exam format?](#what-is-the-exam-format)

---

## What is the CKA Certification?

The **Certified Kubernetes Administrator (CKA)** certification is designed to ensure that holders have the skills, knowledge, and competency to perform the responsibilities of Kubernetes Administrators. It validates that a certified administrator can establish their credibility and value in the job market, and allows companies to hire high-quality teams to support their Kubernetes operations.

**CKA vs CKAD vs CKS:**

| Certification | Focus | Prerequisite |
|--------------|-------|-------------|
| **CKA** | Cluster administration, infrastructure, operations | None |
| **CKAD** | Application design, build, deploy on Kubernetes | None |
| **CKS** | Container & Kubernetes security | Must hold a valid CKA |

---

## How much does the exam cost?

**$395 USD** (single exam). Bundle prices vary. Check the [Linux Foundation Training & Certification Catalog](https://training.linuxfoundation.org/) for current pricing.

> [!TIP]
> **Discount codes** are frequently available. Check the repo [README.md](./README.md) for current coupon codes.
> Bundles (CKA + CKAD, CKA + CKS) often offer significant savings.

---

## How long is the exam?

**2 hours** for the CKA exam.

The exam consists of **15–20 performance-based tasks** to be completed entirely on the command line (Linux). There are no multiple choice questions.

---

## What score is needed to pass?

| Exam | Passing Score |
|------|:------------:|
| **CKA** | **66%** or above |
| **CKAD** | 66% or above |
| **CKS** | 67% or above |

---

## How is the exam scored?

- Exams are scored **automatically** upon completion.
- A score report will be emailed within **24 hours** from the time the exam was completed.
- Barring technical exceptions, results are prompt.

---

## What Kubernetes version is used?

| Exam | Kubernetes Version |
|------|--------------------|
| **CKA** | **v1.35** |
| **CKAD** | v1.35 |
| **CKS** | v1.34 |

> [!NOTE]
> The exam environment is aligned with the most recent Kubernetes minor version within approximately **4–8 weeks** of the official K8s release date. Check the [LF instructions page](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad) for the latest confirmed version.

---

## What resources are allowed during the exam?

You may open **one additional browser tab** pointing to any of these official sites:

- **[kubernetes.io/docs](https://kubernetes.io/docs)** — Official Kubernetes documentation
- **[kubernetes.io/blog](https://kubernetes.io/blog)** — Kubernetes blog
- **[helm.sh/docs](https://helm.sh/docs)** — Helm documentation

> [!WARNING]
> No other external websites, printed notes, books, or personal notes are permitted.
> See the official [Allowed Resources page](https://docs.linuxfoundation.org/tc-docs/certification/certification-resources-allowed#certified-kubernetes-administrator-cka-and-certified-kubernetes-application-developer-ckad) for the authoritative list.

---

## How is the exam proctored?

The exam is **proctored remotely** via:
- Streaming **audio** feed
- Streaming **video** (webcam) feed
- **Screen sharing** (proctors can see all monitors)

The session recording is stored and may be reviewed after exam completion.

**Proctor role:** Proctors facilitate check-in and monitor the session. They do **not** provide technical guidance on exam content.

You can watch a [PSI Online Proctoring Experience video](https://psi.wistia.com/medias/5kidxdd0ry) to understand what to expect.

---

## What are the system requirements?

- **OS:** See [PSI System Requirements](https://helpdesk.psionline.com/hc/en-gb/articles/4409608794260-PSI-Bridge-Platform-System-Requirements)
- **Browser:** All browsers supported; Google Chrome **highly recommended** (Secure Browser is Chrome-based)
- **Monitor:** One active monitor only — **Dual monitors NOT supported**
- **Screen:** ≥ 15" recommended; 1080p resolution recommended
- **Internet:** Reliable connection required (wired preferred)
  - Disable bandwidth-heavy services (Dropbox, BitTorrent, etc.)
  - HTTPS to AWS S3 endpoints must not be blocked by firewall/proxy
- **Microphone:** Required and must be tested before exam
- **Webcam:** Must be moveable (for room pan); no other apps may run

> [!IMPORTANT]
> - Do **NOT** use a virtual machine to take the exam (even if the compatibility check passes)
> - Do **NOT** use a corporate/work-issued machine if possible (security features can disrupt PSI)
> - Disable antivirus scanning during the exam
> - Keep laptop plugged in to power

---

## What are the testing environment requirements?

| Requirement | Details |
|-------------|---------|
| **Desk** | Clutter-free — no paper, electronics, or other objects |
| **Walls** | Clear of paper/printouts (decorative paintings are OK) |
| **Lighting** | Well-lit so proctor can see face, hands, and workspace |
| **Background** | No bright lights or windows directly behind you |
| **Location** | Private, quiet room — no coffee shops or open offices |
| **Camera frame** | You must remain visible throughout the exam |

---

## What ID is required?

- Must be a **valid (unexpired)** government-issued **original** physical document (not a photocopy or digital copy)
- Must include: **name**, **photo**, and **signature** *(government biometric IDs without signature are accepted)*
- **Name on ID must exactly match** the verified name on your LF exam checklist

**Accepted forms of ID:**
- International travel passport
- Government-issued driver's license/permit
- Government-issued local language ID (with photo and signature)
- National identity card / State or province-issued identity card
- Alien registration card (green card / permanent resident / visa)
- 住民基本台帳 (Basic Resident Register with photo) or マイナンバーカード (My Number Card)

**Minors (age 16–18):** A Parent/Guardian must complete a [Parental Release form](https://training.linuxfoundation.org/parental-release-for-testing-of-minors/) at least 2 weeks before the exam. A guardian must also present valid ID and provide verbal consent during check-in.

---

## What languages is the exam available in?

CKA exam tasks are available in:
- 🇺🇸 English
- 🇨🇳 Simplified Chinese
- 🇯🇵 Japanese

The exam defaults to the language detected in your browser. You can switch languages during the exam using the "Language Control Dropdown" in the Content Panel.

---

## How long is the certification valid?

**2 years** from the date the exam is passed.

> [!NOTE]
> CKA and CKAD certifications earned **before April 1, 2024** are valid for **3 years**.

---

## How do I renew my certification?

- Retake and pass the exam **before** the expiration date.
- The renewed certification will be valid for a further **2 years** from the date the exam is passed.

---

## Where can I find practice questions / a simulator?

When you register for the CKA exam, you receive access to the **[Killer.sh](https://killer.sh) exam simulator**:

- **2 attempts** per exam registration
- Each attempt grants **36 hours of access** from activation time
- Simulates the real exam environment and question style
- Harder than the real exam — excellent preparation

> [!NOTE]
> Killer.sh access is **not** included in `CKA-SINGLE` exam registrations.

Access it via: [My Portal](https://trainingportal.linuxfoundation.org) → Start/Resume → Preparing for the Exam section.

Also check the practice questions in this repo: 📝 [PRACTICE_QUESTIONS.md](./PRACTICE_QUESTIONS.md)

---

## Is there training to prepare for the exam?

The Linux Foundation offers official training:

| Course | Description |
|--------|-------------|
| [Introduction to Kubernetes (free)](https://training.linuxfoundation.org/linux-courses/system-administration-training/introduction-to-kubernetes) | Introductory concepts |
| [Kubernetes Fundamentals (LFS258)](https://training.linuxfoundation.org/linux-courses/system-administration-training/kubernetes-fundamentals) | Aligned with CKA content |
| [Kubernetes for Developers (LFS259)](https://training.linuxfoundation.org/training/kubernetes-for-developers/) | Aligned with CKAD content |
| [Kubernetes Security Essentials (LFS260)](https://training.linuxfoundation.org/training/kubernetes-security-essentials-lfs260/) | Aligned with CKS content |

---

## Can I retake the exam if I fail?

**Yes.** The CKA exam registration includes **one free retake**.

The retake must be scheduled and completed within **12 months** of the original purchase date.

---

## What is the exam format?

- **Type:** Performance-based (hands-on, command-line tasks)
- **Tasks:** 15–20 scenario-based problems
- **Environment:** Remote desktop running Linux, with a terminal and Firefox
- **No multiple choice** — every task requires you to actually do the work in a live Kubernetes cluster
- **Pre-installed tools:** `kubectl` (with `k` alias + bash completion), `yq`, `curl`, `wget`, `man`
- **Node access:** SSH from the base node to designated task nodes; `sudo -i` for root

---

> 📚 Related: [EXAM_DAY_GUIDE.md](./EXAM_DAY_GUIDE.md) | [EXAM_TIPS.md](./EXAM_TIPS.md) | [SYLLABUS.md](./SYLLABUS.md) | [CHEATSHEET.md](./CHEATSHEET.md)
