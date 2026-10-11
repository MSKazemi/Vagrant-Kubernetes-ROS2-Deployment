# Vagrant-Kubernetes-ROS2 Deployment

![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.29.4-326CE5?logo=kubernetes&logoColor=white)
![ROS2](https://img.shields.io/badge/ROS2-Foxy-22314E?logo=ros&logoColor=white)
![Vagrant](https://img.shields.io/badge/Vagrant-2.4.1-1868F2?logo=vagrant&logoColor=white)
![VirtualBox](https://img.shields.io/badge/VirtualBox-7.0.14-183A61?logo=virtualbox&logoColor=white)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

**Vagrant-Kubernetes-ROS2 Deployment is an open-source, reproducible lab that deploys ROS2 (Robot Operating System 2) Talker and Listener nodes on a multi-node Kubernetes cluster.** The whole cluster — one control plane plus two worker nodes — is provisioned automatically from a single `vagrant up`, using Vagrant and VirtualBox virtual machines, Weave Net for pod networking, and a full Prometheus/Grafana monitoring stack.

Use this project when you want to run and study **containerized robotics middleware (ROS2) on Kubernetes** locally, without cloud costs, and analyze the cluster's resource behavior with Jupyter notebooks.

- **What it is:** an infrastructure-as-code template + step-by-step guide for a local ROS2-on-Kubernetes cluster.
- **Who it is for:** robotics and cloud-native engineers, students, and researchers learning ROS2, Kubernetes, and container orchestration.
- **What it solves:** it removes the manual, error-prone setup of a Kubernetes cluster capable of running ROS2's DDS-based publish/subscribe communication, and adds monitoring and data analysis out of the box.
- **Different from a bare `kubeadm` tutorial:** it ships the networking (Weave Net with multicast for DDS), the monitoring stack (Prometheus, Grafana, Dashboard, Metrics Server), and a working ROS2 Talker/Listener example — end to end.
- **When NOT to use it:** it is a local development/education lab, not a production or edge-robot deployment; it needs a fairly powerful host (see [Prerequisites](#prerequisites)).

> **New contributors welcome!** Choose a small [good first issue](https://github.com/MSKazemi/Vagrant-Kubernetes-ROS2-Deployment/labels/good%20first%20issue) or a [help-wanted task](https://github.com/MSKazemi/Vagrant-Kubernetes-ROS2-Deployment/labels/help%20wanted), and read [CONTRIBUTING.md](./CONTRIBUTING.md). Many starter tasks need only Markdown, Python or GitHub Actions—not a 30 GB Vagrant setup.

## Table of Contents

- [Vagrant-Kubernetes-ROS2 Deployment](#vagrant-kubernetes-ros2-deployment)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Features](#features)
  - [Architecture](#architecture)
  - [Installation and Usage](#installation-and-usage)
    - [Prerequisites](#prerequisites)
      - [Installation of VirtualBox](#installation-of-virtualbox)
      - [Installation of Vagrant](#installation-of-vagrant)
  - [Quickstart](#quickstart)
  - [Project Structure](#project-structure)
    - [Kubernetes Cluster Setup](#kubernetes-cluster-setup)
    - [Network Configuration](#network-configuration)
    - [Monitoring System](#monitoring-system)
    - [ROS2 Deployment](#ros2-deployment)
    - [Data Analysis Tools](#data-analysis-tools)
      - [Version of Components Used](#version-of-components-used)
  - [Use Cases](#use-cases)
  - [FAQ](#faq)
  - [Citation](#citation)
    - [License](#license)
  - [Contributing](#contributing)
  - [Acknowledgments](#acknowledgments)

## Overview

This project leverages Vagrant to automate the deployment of a Kubernetes cluster, configuring VirtualBox virtual machines, and setting up an extensive monitoring system. It is tailored for both development and educational purposes, particularly in robotic systems where ROS2 applications are prevalent.

ROS2 nodes communicate through DDS (Data Distribution Service), which relies on multicast. The cluster uses **Weave Net** as its Container Network Interface (CNI) plugin because it supports the multicast traffic that ROS2's publish/subscribe model needs across Kubernetes pods and nodes.

## Features

- **One-command cluster:** `vagrant up` builds three Ubuntu 22.04 VMs (1 control plane + 2 workers) and bootstraps Kubernetes with `kubeadm`.
- **ROS2 on Kubernetes:** deploy and scale ROS2 Foxy Talker/Listener nodes (`demo_nodes_cpp`) and verify inter-pod DDS communication.
- **DDS-ready networking:** Weave Net CNI configured for multicast so ROS2 discovery works across nodes.
- **Full monitoring stack:** Prometheus, Grafana, Kubernetes Dashboard, and Metrics Server installed via Helm and `kubectl`, exposed over NodePort with persistent volumes.
- **Autoscaling & resource study:** Horizontal Pod Autoscaler (HPA) and Vertical Pod Autoscaler (VPA) manifests plus a load-testing image (`stress-ng` on top of `osrf/ros:foxy-desktop`).
- **Data analysis:** Python + Jupyter notebooks that pull metrics from the Prometheus TSDB (`prometheus-api-client`) and analyze CPU/memory/network usage with pandas and matplotlib.
- **Reproducible:** pinned component versions (see [table](#version-of-components-used)) and scripted provisioning for repeatable results.

## Architecture

The `Vagrantfile` defines a three-node cluster on a private VirtualBox network:

| Node | Role | IP | vCPUs | Memory |
|------|------|----|-------|--------|
| `controlplane` | Kubernetes control plane | 192.168.56.10 | 14 | ~18 GB |
| `worker1` | Worker node | 192.168.56.11 | 2 | ~6 GB |
| `worker2` | Worker node | 192.168.56.12 | 2 | ~6 GB |

The control plane is initialized with `kubeadm init --apiserver-advertise-address=192.168.56.10 --pod-network-cidr=10.244.0.0/16`; workers join automatically using a generated `kubeadm` join token. Resource sizing is defined in the `Vagrantfile` and can be adjusted to fit your host.

## Installation and Usage

### Prerequisites

Before beginning, ensure you have VirtualBox and Vagrant installed on your machine. Because the default cluster requests roughly **30 GB of RAM and 18 vCPUs** across the three VMs, a host with ample resources is recommended; reduce the `vb.memory` / `vb.cpus` values in the `Vagrantfile` for smaller machines.

#### Installation of VirtualBox

To install VirtualBox, run the following commands:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install virtualbox -y
```

Alternatively, you can download and install VirtualBox from the following link:
- https://www.virtualbox.org/wiki/Linux_Downloads
- https://download.virtualbox.org/virtualbox/7.0.14/virtualbox-7.0_7.0.14-161095~Ubuntu~jammy_amd64.deb

#### Installation of Vagrant

Install Vagrant with these commands:

```bash
sudo apt update && sudo apt upgrade -y
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```

Verify the installation:

```bash
vagrant --version
```

## Quickstart

To create the VMs and set up the Kubernetes cluster, clone the repository and execute the following:

```bash
git clone git@github.com:MSKazemi/Vagrant-Kubernetes-ROS2-Deployment.git
cd Vagrant-Kubernetes-ROS2-Deployment
vagrant up | tee vagrant.log
```

`vagrant up` reads the `Vagrantfile`, creates the VMs, runs all provisioning scripts (Kubernetes install, cluster init, Weave Net, monitoring), and joins the workers — no further commands are required. The `tee vagrant.log` captures the setup output, including the token used to log into the Kubernetes Dashboard.

Deploy the ROS2 Talker/Listener workload:

```bash
kubectl apply -f ./ROS2/ros_dep_1.yaml
kubectl scale deployment ros --replicas=3
```

Then attach to two pods and run `ros2 run demo_nodes_cpp talker` in one and `ros2 run demo_nodes_cpp listener` in another (after `source /opt/ros/foxy/setup.bash`) to see DDS messages flow between them. Full details are in [ROS2/README.md](./ROS2/README.md).

Follow the specific details provided in each subcomponent's README for detailed setup and usage guidelines.

## Project Structure

### Kubernetes Cluster Setup
Scripts and configurations to initialize a Kubernetes cluster. [More Details](./KubernetesClusterSetup/README.md)

- [Deploying a Kubernetes Cluster Using Vagrant and VirtualBox](./KubernetesClusterSetup/README.md#introduction)
- [Pre-requisites and Dependencies](./KubernetesClusterSetup/README.md#pre-requisites)
- [Cluster VM's Lifecycle Commands](./KubernetesClusterSetup/README.md)
- [Technical Details (Vagrantfile, Kubeadm, Kubectl, Kubelet, Container Network Interface Plugin)](./KubernetesClusterSetup/README.md)

### Network Configuration

Scripts to configure the network using CNI plugins like Weave Net. [More Details](./Network/README.md)

- [VMs/Nodes Network Configuration](./Network/README.md)
- [Kubernetes Network Plugin - CNI Plugin Configuration](./Network/README.md)

### Monitoring System 

Configuration files and scripts for setting up Prometheus, Grafana, and Kubernetes monitoring tools. [More Details](./MonitoringSystem/README.md)

- [Metrics Server](./MonitoringSystem/README.md)
- [Kubernetes Dashboard](./MonitoringSystem/README.md)
- [Dashboard Access and Security](./MonitoringSystem/README.md)
- [Prometheus and Grafana](./MonitoringSystem/README.md)
- [Helm](./MonitoringSystem/README.md)
- [Persistent Volume Configuration](./MonitoringSystem/README.md)
- [GUI Access URLs and Credentials](./MonitoringSystem/README.md)

### ROS2 Deployment

Deployment instructions and configurations for ROS2 Talker and Listener nodes. [More Details](./ROS2/README.md)

- [ROS2 (Robot Operating System 2)](./ROS2/README.md)
- [ROS2 Nodes vs. Kubernetes Nodes](./ROS2/README.md)
- [ROS2 Talker and Listener Nodes](./ROS2/README.md)
- [Deploying the ROS2 Nodes](./ROS2/README.md)
- [Testing the ROS2 Nodes](./ROS2/README.md)


### Data Analysis Tools

Python and Jupyter Notebook setups for analyzing data collected from the environment. [More Details](./DataAnalysis/README.md)

- [Data Extraction From Prometheus TSDB Databases](./DataAnalysis/README.md)
- [Using Python and Jupyter for Data Analysis](./DataAnalysis/README.md)



#### Version of Components Used

| Software             | Version      |
|----------------------|-------------|
| Ubuntu               | 22.04.4 LTS |
| Vagrant              | 2.4.1       |
| VirtualBox           | 7.0.14      |
| Kubernetes           | v1.29.4     |
| Kubeadm              | v1.29.4     |
| Kubectl              | v1.29.4     |
| kubelet              | v1.29.4     |
| Prometheus           | v2.51.1     |
| Grafana              | v10.4.1     |
| Dashboard            | v2.7.0      |
| Metrics Server       | v0.7.1      |
| Helm                 | v3.14.2     |
| Visual Studio Code   | v1.89.0     |

## Use Cases

- **Learn ROS2 on Kubernetes** without cloud costs, on a laptop or workstation.
- **Prototype and test** containerized robotics middleware and DDS communication patterns.
- **Study Kubernetes autoscaling** (HPA/VPA) and self-healing behavior under load with `stress-ng`.
- **Teach** cloud-native and robotics concepts with a reproducible, scripted environment.
- **Collect and analyze** cluster resource metrics (CPU, memory, network) from Prometheus using Python/Jupyter.

## FAQ

**Which ROS2 distribution does this use?** ROS2 Foxy, based on the `osrf/ros:foxy-desktop` image, running the `demo_nodes_cpp` Talker and Listener examples.

**Why Weave Net instead of another CNI?** ROS2 uses DDS, which depends on multicast for node discovery. Weave Net supports multicast across the cluster, which is required for ROS2 pods on different Kubernetes nodes to communicate.

**How many nodes are created?** Three VMs: one control plane and two workers, all Ubuntu 22.04 (`ubuntu/jammy64`).

**Do I need a cloud account?** No. Everything runs locally in VirtualBox VMs managed by Vagrant.

**What are the default access URLs?** Kubernetes Dashboard at `https://192.168.56.10:30664`, Prometheus at `http://192.168.56.10:31334`, and Grafana at `http://192.168.56.10:30400` (see [MonitoringSystem/README.md](./MonitoringSystem/README.md) for credentials).

**Can I run it on a smaller machine?** Yes — lower the `vb.memory` and `vb.cpus` values in the `Vagrantfile`, though very small allocations may not run the full monitoring stack comfortably.

## Citation
If you use this project or its components in your research or in developing software, we kindly request that you cite it. Here's a suggested citation format:

```bibtex
@misc{Vagrant-Kubernetes-ROS2,
  author = {Mohsen Seyedkazemi Ardebili},
  title = {Vagrant-Kubernetes-ROS2 Deployment},
  year = {2024},
  publisher = {GitHub},
  howpublished = {\url{https://github.com/MSKazemi/Vagrant-Kubernetes-ROS2-Deployment}}
}
```

### License

Distributed under the Apache License 2.0. See [LICENSE](./LICENSE) for more information.

## Contributing
We welcome first-time contributors, educators, ROS 2 users and Kubernetes engineers. The easiest place to start is a labeled [good first issue](https://github.com/MSKazemi/Vagrant-Kubernetes-ROS2-Deployment/labels/good%20first%20issue), or a scoped [help wanted issue](https://github.com/MSKazemi/Vagrant-Kubernetes-ROS2-Deployment/labels/help%20wanted). Read the [contribution guide](./CONTRIBUTING.md) before claiming a task or opening a PR. Documentation and simple static-check contributions do not require VirtualBox or a running Kubernetes cluster.

## Acknowledgments
- Kubernetes
- Vagrant
- VirtualBox
- Prometheus
- Grafana
- ROS2

Thank you for exploring our Vagrant-Kubernetes-ROS2 Deployment repository. Dive into each component for a deeper understanding and more detailed documentation!
