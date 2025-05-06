## Install Latest VirtualBox

> Note: You should have admin permission in your workstation to make Virtaualbox work.

Download and install virtual box from https://www.virtualbox.org/wiki/Downloads

## Install Vagrant

Install Vagrant followin insructions from https://developer.hashicorp.com/vagrant/downloads

## Restart the System

Once all the installation is done, restart the system.

## Bring up the VMS

Clone the cka certification repo.

```
git clone https://github.com/techiescamp/cka-certification-guide.git
```

Now, open the terminal and cd in the lab-setup/windows folder.

```
cd lab-setup/windows 
```

Execute the following command to bring up the VMs

```
vagrant up
```
Check the vm status using the following command. You should see three VMs in running state.

```
vagrant status
```

Once the VMs are up, you cna login to the VMs using the VM names.

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

You can access all the files added to the lab-setup/windows folder inside the `/vagrant` folder.
