## Install Multipass

Download and install Multipass for macOS (Apple Silicon) from the official site:

https://multipass.run/install

---

## Bring Up the VMs

Clone the repo and cd into this folder:

```bash
git clone https://github.com/techiescamp/cka-certification-guide.git
cd lab-setup/multipass
```

Make the scripts executable and launch all VMs:

```bash
chmod +x launch.sh refresh-hosts.sh
./launch.sh
```

This will:
1. Launch **controlplane**, **node01**, and **node02** using Ubuntu 24.04
2. Discover their IPs (assigned via DHCP by Multipass)
3. Inject hostname entries into `/etc/hosts` on each VM so they can resolve each other by name

At the end, the script prints the IPs so you can optionally add them to your Mac's `/etc/hosts` as well.

---

## Connect to VMs

```bash
multipass shell controlplane
multipass shell node01
multipass shell node02
```

---

## Stop the VMs

```bash
multipass stop controlplane node01 node02
```

---

## Start the VMs Again

After stopping and starting, IPs may change. Run the refresh script to re-sync `/etc/hosts`:

```bash
multipass start controlplane node01 node02
./refresh-hosts.sh
```

---

## Destroy the Setup

```bash
multipass delete controlplane node01 node02
multipass purge
```

---

## VM Configuration

Edit `settings.yaml` to adjust resources before running `launch.sh`:

| VM           | CPUs | Memory | Disk |
|--------------|------|--------|------|
| controlplane | 2    | 2G     | 20G  |
| node01       | 1    | 2G     | 20G  |
| node02       | 1    | 2G     | 20G  |

---

## Accessing Files from the Host

Transfer a file into a VM:

```bash
multipass transfer ./myfile.yaml controlplane:/home/ubuntu/myfile.yaml
```

Transfer a file from a VM to the host:

```bash
multipass transfer controlplane:/home/ubuntu/somefile.yaml .
```
