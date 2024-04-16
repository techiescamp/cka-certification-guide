require 'yaml'
settings = YAML.load_file(File.join(File.dirname(__FILE__), 'settings.yaml'))

Vagrant.configure("2") do |config|
  config.vm.box = settings['box_name']
  config.vm.box_check_update = true
  # config.ssh.private_key_path = "/Users/apple/.ssh/id_rsa"

  settings['vm'].each do |vm_config|
    config.vm.define vm_config['name'] do |vm|
      vm.vm.hostname = vm_config['name']
      vm.vm.network "private_network", ip: vm_config['ip']
      vm.vm.synced_folder ".", "/vagrant"

      vm.vm.provider "virtualbox" do |vb|
        vb.memory = vm_config['memory']
        vb.cpus = vm_config['cpus']
        vb.gui = false
      end

      vm.vm.provision "shell", inline: <<-SHELL
        apt-get update -y
        echo "192.168.201.10 controlplane" >> /etc/hosts
        echo "192.168.201.11 node01" >> /etc/hosts
        echo "192.168.201.12 node02" >> /etc/hosts
      SHELL
    end
  end
end
