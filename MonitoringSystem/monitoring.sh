#!/bin/bash
echo "Installing monitoring tools"


# Install Metrics Server
echo "Installing Metrics Server"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml


# Install Kubernetes Dashboard
echo "Installing Kubernetes Dashboard"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml


echo "Creating admin-user for dashboard"
kubectl apply -f /home/vagrant/codes/MonitoringSystem/admin-user.yaml



# Dashboard token
echo "Dashboard token saved to token file"
kubectl -n kubernetes-dashboard get secret/admin-user -o go-template="{{.data.token | base64decode}}" >> "token"
echo "Dashboard token:"
# kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token (Maybe Wrong)
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')


# Install Helm
echo "Installing Helm"
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm


# Persistent Volume for Prometheus and Grafana
echo "Creating Persistent Volume for Prometheus and Grafana"
kubectl apply -f /home/vagrant/codes/MonitoringSystem/pv.yaml


# Install Prometheus
echo "Prometheus"
echo "Adding Prometheus Helm repository"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


# Create directories and set permissions
for i in {1..5}; do
    sudo mkdir -p "/mnt/data$i"         # '-p' ensures the directory is created if it does not exist and does not throw an error if it does
    sudo chmod -R 777 "/mnt/data$i"       # Corrected to use uppercase 'R' if recursion is needed
done
sudo chmod -R 777 /mnt/

echo "Creating namespace for Prometheus"
kubectl create namespace prometheus

echo "Installing Prometheus"
helm install prometheus prometheus-community/kube-prometheus-stack -n prometheus --values /home/vagrant/codes/MonitoringSystem/kube-prometheus-stack-values.yaml
# helm install prometheus prometheus-community/kube-prometheus-stack -n prometheus -f     kube-prometheus-stack-values.yaml
 