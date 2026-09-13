<div align="center">

# 🛣️ OpenShift Application Routing and Load Balancing

![OpenShift](https://img.shields.io/badge/OpenShift-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Networking](https://img.shields.io/badge/Networking-Routes%20%26%20Load%20Balancing-blue?style=for-the-badge)
![Certification](https://img.shields.io/badge/Red%20Hat-Certified%20OpenShift%20Application%20Developer-red?style=for-the-badge&logo=redhat&logoColor=white)

*Exposing and balancing traffic across OpenShift applications with Routes*

</div>

---

## 📑 Table of Contents

- [🎯 Overview](#-overview)
- [🏆 Key Achievements](#-key-achievements)
- [💡 Why This Matters](#-why-this-matters)
- [🚀 Looking Ahead](#-looking-ahead)
- [📚 Key Concepts](#-key-concepts)

---

## 🎯 Overview

This lab focused on exposing applications running inside an OpenShift cluster to external traffic using **Routes**, and on distributing that traffic intelligently across multiple application instances.

---

## 🏆 Key Achievements

In this lab, you have successfully:

- 🌐 **Created OpenShift Routes** — exposed internal services to external traffic, making applications accessible from outside the cluster
- 🧭 **Implemented Path-Based Routing** — served multiple applications from a single hostname using different URL paths, optimizing resource usage and simplifying DNS management
- ⚖️ **Configured Load Balancing Strategies** — distributed traffic across multiple application instances to improve performance and reliability
- 🔒 **Explored Advanced Routing Features** — including secure HTTPS routes and multi-service load balancing

---

## 💡 Why This Matters

These skills are essential for **Red Hat Certified OpenShift Application Developer** certification and real-world OpenShift deployments. Routes are the primary mechanism for exposing applications in OpenShift, and understanding how to configure them properly ensures your applications are accessible, secure, and performant.

---

## 🚀 Looking Ahead

The concepts you've learned here form the foundation for more advanced topics like service mesh, API gateways, and enterprise-grade application exposure strategies. Practice these techniques in different scenarios to build confidence in managing OpenShift application networking.

---

## 📚 Key Concepts

| Concept | Description |
|---|---|
| **Route** | The OpenShift resource that exposes a Service at an externally-reachable hostname |
| **Path-Based Routing** | Routing multiple applications through one hostname by distinguishing traffic via URL path |
| **Load Balancing** | Distributing incoming traffic across multiple instances of an application |
| **HTTPS Route (TLS)** | A secure Route configuration that encrypts traffic between clients and the cluster |
| **Multi-Service Load Balancing** | Balancing traffic across several backing Services from a single routing layer |

---

<div align="center">

**🎓 Al Nafi — Cybersecurity & Cloud Training Labs**

</div>
