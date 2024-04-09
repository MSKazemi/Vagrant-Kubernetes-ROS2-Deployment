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
kubeadm token create --print-join-command > /vagrant/join-command.sh

# Auto-completion for kubectl
sudo apt-get update
sudo apt-get -y install bash-completion
kubectl completion bash > ~/.kube/kubectl_bash_completion
echo "source /home/vagrant/.kube/kubectl_bash_completion" >> ~/.bashrc
source /home/vagrant/.bashrc