## Install Latest VirtualBox & Vagrant

Follow the instructions given in the following blog to set up **VirtualBox** and **Vagrant** on Mac M-series.

**Detailed Blog:** [Setup VirtualBox & Vagrant](https://developer.hashicorp.com/vagrant/downloads)

You can download the latest Apple Silicon (ARM64) build of VirtualBox from the official  
[VirtualBox Downlaods](https://www.virtualbox.org/wiki/Downloads).

---

## Restart the System

Once all the installation is done, restart the system.

---

## Bring up the VMS

> You may encounter  networking errors during Vagrant setup due to permission issues. Most of these errors are discussed on Stack Overflow and GitHub. A simple Google search should help resolve these issues.

Clone the cka certification repo.

```
git clone https://github.com/techiescamp/cka-certification-guide.git
```

Now, open the terminal and cd in the lab-setup/mac-silicon folder.

```
cd lab-setup/mac-silicon 
```

> Note: You have to use sudo with all the vagrant commands.

Execute the following command to bring up the VMs

```
sudo vagrant up
```

Once the VMs are up, you can login to the VMs using the VM names.

```
vagrant ssh controlplane
vagrant ssh node01
vagrant ssh node02
```

## Halt the VMs

When you are not using the setup, you can halt the VMS to free up the CPU and memory in your system using the halt command.

```
vagrant halt
```

## Destroy the setup

You can destroy the VMs usin the following command.

```
vagrant destroy -f
```

## Accessing The Shared Folder

The `/vagrant` folder inside the VM is shared with the host operating system.

You can access all the files added to the lab-setup/mac-silicon folder inside the `/vagrant` folder.
