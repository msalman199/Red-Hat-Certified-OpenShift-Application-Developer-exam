<div align="center">

# 🏗️ Deploying a Three-Tier Application on OpenShift with Autoscaling & Load Testing

![OpenShift](https://img.shields.io/badge/OpenShift-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Red Hat](https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

</div>

---

## 📖 Table of Contents

- [📋 Overview](#-overview)
- [📝 Lab Summary](#-lab-summary)
- [💡 Why This Matters](#-why-this-matters)
- [📚 Key Concepts](#-key-concepts)
- [🚀 Next Steps](#-next-steps)
- [🏁 Conclusion](#-conclusion)

---

## 📋 Overview

This lab walked through the full lifecycle of a **three-tier application** on OpenShift — from source code to a production-hardened, load-tested deployment.

---

## 📝 Lab Summary

In this lab you designed, containerized, and deployed a complete three-tier application on OpenShift, moving from source code and Dockerfiles through image builds, database schema initialization, service networking, and a public Route. You then layered in production concerns by configuring horizontal pod autoscaling, resource quotas, and limit ranges, and validated the whole system under load using a custom concurrent load-testing script while diagnosing real failure modes such as missing tables, empty service endpoints, and stale HPA metrics.

---

## 💡 Why This Matters

These are the same skills exercised on the **Red Hat Certified OpenShift Application Developer** exam: building and deploying applications, wiring up storage and networking, and troubleshooting a live cluster under pressure.

---

## 📚 Key Concepts

| Concept | Description |
|---|---|
| **Three-Tier Architecture** | An application split into presentation, application, and data layers, each deployed as its own OpenShift workload |
| **Database Schema Initialization** | Setting up the required tables/structures in the data tier before the application can serve requests |
| **Service Networking** | Kubernetes Services that provide stable internal endpoints for communication between application tiers |
| **Route** | The OpenShift resource that exposes a service for external, public access |
| **Horizontal Pod Autoscaler (HPA)** | Automatically scales pod replicas based on observed metrics such as CPU or memory usage |
| **Resource Quota** | Namespace-level limits on aggregate resource consumption (CPU, memory, object counts) |
| **LimitRange** | Default and boundary constraints on resource requests/limits for individual pods/containers within a namespace |
| **Load Testing** | Simulating concurrent traffic against a deployed application to validate behavior and scaling under load |
| **Service Endpoint** | The actual pod IP(s) backing a Service; an empty endpoint set indicates no healthy pods are matched |
| **HPA Metrics Staleness** | A troubleshooting condition where the autoscaler acts on outdated metric data, delaying correct scaling decisions |

---

## 🚀 Next Steps

From here, students should explore extending this pipeline with OpenShift Pipelines (Tekton) for automated builds and deployments, adding Prometheus ServiceMonitors and Grafana dashboards for deeper observability, and experimenting with StatefulSets or an operator-managed database for more resilient persistent storage.

---

## 🏁 Conclusion

This lab tied together the full application lifecycle on OpenShift — build, deploy, network, scale, and troubleshoot — reinforcing the core competencies required for real-world OpenShift application development.

<div align="center">

**Made with ❤️ for Al Nafi Training Labs**

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Training%20Labs-blue?style=for-the-badge)

</div>
