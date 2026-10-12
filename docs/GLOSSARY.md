# Beginner Glossary: ROS 2 and Kubernetes

This document provides simple, plain-English definitions for the robotics and infrastructure terminology used throughout this lab to help you understand how ROS 2 and Kubernetes interact.

## Kubernetes Terminology

* **Kubernetes node**: A physical or virtual machine (like the Vagrant VMs provisioned in this lab) that provides computing resources. A group of these machines forms a Kubernetes cluster.
* **Kubernetes pod**: The smallest deployable computing unit in Kubernetes, which encapsulates one or more containers. For example, a *Kubernetes pod* in this lab might host a container running a *ROS 2 node* that is responsible for publishing sensor data to a *ROS topic*. [Read more about Pods](https://kubernetes.io/docs/concepts/workloads/pods/).
* **Deployment**: A Kubernetes controller that manages the creation, updating, and scaling of identical pods, ensuring the desired number of application replicas are always running.
* **namespace**: A mechanism used to isolate and logically organize resources within the same cluster, acting as a "virtual cluster" to prevent interference between different projects.
* **CNI (Container Network Interface)**: The networking component responsible for allocating IP addresses to pods and enabling them to communicate across different Kubernetes nodes.
* **Service**: A Kubernetes abstraction that defines a logical set of pods and a network policy to access them. It provides a stable IP address even as the underlying pods are destroyed or recreated.
* **HPA (Horizontal Pod Autoscaler)**: An autoscaling tool that dynamically increases or decreases the number of running pods based on current system load.
* **VPA (Vertical Pod Autoscaler)**: A tool that automatically adjusts the CPU and memory resource limits provided to an existing pod based on its historical usage.

## ROS 2 and DDS Terminology

* **ROS 2 node**: A single, executable software process that performs computation. Unlike a *Kubernetes node* (which is a machine), a *ROS 2 node* is simply a software application running on that infrastructure. [Read more about ROS 2 Nodes](https://docs.ros.org/en/rolling/Concepts/Basic/About-Nodes.html).
* **topic**: A named communication bus or channel over which ROS 2 nodes exchange streaming messages.
* **publish/subscribe**: The primary messaging pattern in ROS 2 where a sender (publisher) broadcasts data without knowing who is receiving it, and a receiver (subscriber) listens for that specific data.
* **DDS (Data Distribution Service)**: The underlying industrial networking standard ROS 2 uses for real-time communication. While DDS often uses multicast traffic to find other devices on a local network, it does **not** always require multicast; explicit peer-to-peer or discovery-server options exist for environments that block multicast traffic.
* **discovery**: The dynamic, automatic process by which ROS 2 nodes find and establish connections with one another over the network.
* **QoS (Quality of Service)**: Network policies in ROS 2 that dictate message delivery behaviors (e.g., guaranteed delivery vs. "best effort"). These are crucial for tuning robotic systems to handle unreliable connections like Wi-Fi.
* **RMW (ROS Middleware) implementation**: The software layer that connects the core ROS 2 code to the specific DDS library being used (such as FastDDS or CycloneDDS). [Read more about RMW](https://docs.ros.org/en/rolling/Concepts/Intermediate/About-Middleware-Implementations.html).
* **ROS_DOMAIN_ID**: A numerical identifier used to logically isolate different ROS 2 networks sharing the same physical network. Only nodes sharing the same domain ID will discover and communicate with each other.

## Additional Tools

* **Prometheus**: An open-source systems monitoring toolkit that collects and stores time-series performance metrics (like CPU and memory usage) from the cluster.
* **Grafana**: A data visualization platform that connects to Prometheus to display interactive dashboards and visual graphs of system metrics.