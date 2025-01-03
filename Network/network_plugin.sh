#!/bin/bash
# Install Weave Net
echo "Installing Weave Net"
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml