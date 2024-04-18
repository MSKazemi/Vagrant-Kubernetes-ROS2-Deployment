# -*- mode: ruby -*-
# vi: set ft=ruby :

vm_name_cp = "controlplane"
vm_name_w1 = "worker1"
vm_name_w2 = "worker2"

vm_ip_cp = "192.168.56.10"
vm_ip_w1 = "192.168.56.11"
vm_ip_w2 = "192.168.56.12"


Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.synced_folder "./", "/home/vagrant/codes/"
  config.vm.provision "shell", path: "./KubernetesClusterSetup/provision_all.sh"
  config.vm.provision "shell", path: "./KubernetesClusterSetup/CRI_DockerEng_containerd.sh"
  config.vm.provision "shell", path: "./KubernetesClusterSetup/kubeadm_kubelet_kubectl.sh"

  config.vm.provision "shell", inline: "echo '#{vm_ip_cp} #{vm_name_cp}' | sudo tee -a /etc/hosts"
  config.vm.provision "shell", inline: "echo '#{vm_ip_w1} #{vm_name_w1}' | sudo tee -a /etc/hosts"
  config.vm.provision "shell", inline: "echo '#{vm_ip_w2} #{vm_name_w2}' | sudo tee -a /etc/hosts"


  # Control Plane Configuration
  config.vm.define vm_name_cp do |cp|
    cp.vm.network "private_network", ip: vm_ip_cp
    cp.vm.hostname = vm_name_cp  # This sets the internal hostname of the VM
    cp.vm.provider "virtualbox" do |vb|
      vb.name = vm_name_cp # This sets the name displayed in VirtualBox
      vb.memory = "18240" # This sets the amount of memory for the VM
      vb.cpus = 14 # This sets the number of CPUs for the VM
    end

    # cluster setup
    cp.vm.provision "shell", path: "./KubernetesClusterSetup/create_cluster.sh"
    
    # Inline shell to perform a check or another sleep
    cp.vm.provision "shell", inline: <<-SHELL
      echo "Waiting for the cluster setup to stabilize..."
      sleep 20
    SHELL

    cp.vm.provision "shell", path: "./Network/network_plugin.sh"
    
    # Inline shell to perform a check or another sleep
    cp.vm.provision "shell", inline: <<-SHELL
      echo "Waiting for the network plugin setup to stabilize..."
      sleep 20
    SHELL
    
    cp.vm.provision "shell", path: "./MonitoringSystem/monitoring.sh"
  end

  # Worker Node 1 Configuration
  config.vm.define vm_name_w1 do |w1|
    w1.vm.network "private_network", ip: vm_ip_w1
    w1.vm.hostname = vm_name_w1 # This sets the internal hostname of the VM
    w1.vm.provider "virtualbox" do |vb|
      vb.name = vm_name_w1 # This sets the name displayed in VirtualBox
      vb.memory = "6096" # This sets the amount of memory for the VM
      vb.cpus = 2 # This sets the number of CPUs for the VM
    end
    w1.vm.provision "shell", inline: "bash /home/vagrant/codes/join-command.sh"
  end


  # Worker Node 2 Configuration
  config.vm.define vm_name_w2 do |w2|
    w2.vm.network "private_network", ip: vm_ip_w2
    w2.vm.hostname = vm_name_w2 # This sets the internal hostname of the VM
    w2.vm.provider "virtualbox" do |vb|
      vb.name = vm_name_w2 # This sets the name displayed in VirtualBox
      vb.memory = "6096" # This sets the amount of memory for the VM
      vb.cpus = 2 # This sets the number of CPUs for the VM
    end
    w2.vm.provision "shell", inline: "bash /home/vagrant/codes/join-command.sh"
  end


end
 
