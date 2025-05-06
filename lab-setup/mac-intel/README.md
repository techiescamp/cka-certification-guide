## Install Latest VirtualBox

> Note: You should have admin permission in your workstation to make Virtaualbox work.

Download and install virtual box from https://www.virtualbox.org/wiki/Downloads

Create/edit the /etc/vbox/networks.conf file and add the following to avoid any network-related issues.

```
* 0.0.0.0/0 ::/0
or run below commands

sudo mkdir -p /etc/vbox/
echo "* 0.0.0.0/0 ::/0" | sudo tee -a /etc/vbox/networks.conf
```

So that the host only networks can be in any range, not just 192.168.56.0/21 as described here: https://discuss.hashicorp.com/t/vagrant-2-2-18-osx-11-6-cannot-create-private-network/30984/23

## Install Vagrant

Install Vagrant followin insructions from https://developer.hashicorp.com/vagrant/downloads

## Restart the System

Once all the installation is done, restart the system.

## Bring up the VMS

> You may encounter  networking errors during Vagrant setup due to permission issues. Most of these errors are discussed on Stack Overflow and GitHub. A simple Google search should help resolve these issues.

Clone the cka certification repo.

```
git clone https://github.com/techiescamp/cka-certification-guide.git
```

Now, open the terminal and cd in the lab-setup/mac-intel folder.

```
cd lab-setup/mac-intel 
```

Execute the following command to bring up the VMs

```
vagrant up
```

Once the VMs are up, you cna login to the VMs using the VM names.

```
vagrant ssh controlplane
vagrant ssh node01
vagrant ssh node01
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

You can access all the files added to the lab-setup/mac-intel folder inside the `/vagrant` folder.
