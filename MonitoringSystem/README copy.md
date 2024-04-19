






#### kubectl create namespace prometheus

```bash

```

#### Install Prometheus using Helm

```bash
kubectl create namespace prometheus
helm install prometheus prometheus-community/kube-prometheus-stack -n prometheus
```



if you want to access the Prometheus dashboard, you can port-forward the Prometheus pod to your local machine:
```bash
kubectl --namespace prometheus port-forward deploy/prometheus-kube-prometheus-prometheus 9090
```
Now, you can access the Prometheus dashboard by navigating to http://localhost:9090 in your web browser.

Or you can change the service type to NodePort or LoadBalancer:
```bash
kubectl -n prometheus edit service prometheus-kube-prometheus-prometheus
```
In the editor, change type: ClusterIP to type: **NodePort** or type: LoadBalancer. Save and exit.
For remote server, you can use the LoadBalancer type.
