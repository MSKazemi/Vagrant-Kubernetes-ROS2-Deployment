#!/bin/bash
# set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo kubeadm init --apiserver-advertise-address=192.168.56.10 --pod-network-cidr=10.244.0.0/16

mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Save the join command to a shared location
kubeadm token create --print-join-command > /home/vagrant/codes/join-command.sh

# Untaint the controlpane node to allow pods to be scheduled on it
# kubernets dashboard
# metrcis server
# prometheus
kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule-  


# Auto-completion for kubectl
sudo apt-get update
sudo apt-get -y install bash-completion

# Add kubectl completion to bash
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'source <(kubectl completion bash)' >> /home/vagrant/.bashrc
