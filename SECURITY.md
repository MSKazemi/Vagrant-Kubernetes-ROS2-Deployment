# Security policy

This repository is an educational and research lab for running ROS 2 on Kubernetes. It is **not** a production or safety-critical platform, and several components are historical (ROS 2 Foxy, Kubernetes 1.29, Weave Net). Security reports are still welcome and taken seriously.

## Reporting a vulnerability

Please **do not open a public issue** for a vulnerability, and never paste credentials, Kubernetes tokens, kubeconfigs or join tokens into an issue, pull request or log. Use either of these private channels:

- **GitHub private reporting (preferred):** [report a vulnerability](https://github.com/MSKazemi/Vagrant-Kubernetes-ROS2-Deployment/security/advisories/new).
- **Email:** [mohsen.seyedkazemi@gmail.com](mailto:mohsen.seyedkazemi@gmail.com), with a subject line starting `[security]`.

Helpful details: what is affected (file, script or manifest), steps to reproduce, and the impact you expect. This project is maintained by volunteers, so replies are best-effort; a report is acknowledged and handled in private until a fix or documented mitigation is available.

## Scope

Only the `main` branch is maintained. In scope: the Vagrant and provisioning scripts, Kubernetes and monitoring manifests, container image recipes, GitHub Actions workflows, and documentation that could lead users into an unsafe setup.

Already known and tracked publicly, so there is no need to report them privately: broad `cluster-admin` and dashboard-token handling ([#6](https://github.com/MSKazemi/Vagrant-Kubernetes-ROS2-Deployment/issues/6), [#4](https://github.com/MSKazemi/Vagrant-Kubernetes-ROS2-Deployment/issues/4)) and the age of historical component versions. Improvements to these are welcome as normal pull requests.
