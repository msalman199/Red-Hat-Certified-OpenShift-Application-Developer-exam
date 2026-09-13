<div align="center">

# 🔐 Managing Configuration and Secrets in OpenShift

![OpenShift](https://img.shields.io/badge/OpenShift-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white)
![ConfigMap](https://img.shields.io/badge/ConfigMap-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Secrets](https://img.shields.io/badge/Secrets-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-CB171E?style=for-the-badge&logo=yaml&logoColor=white)

**Status:** ✅ Completed

</div>

---

## 📑 Table of Contents

- [🔑 Key Concepts](#-key-concepts)
- [🏁 Conclusion](#-conclusion)
  - [📘 What You Learned](#-what-you-learned)
  - [💡 Why This Matters](#-why-this-matters)

---

## 🔑 Key Concepts

| Concept | Description |
|---|---|
| **ConfigMap** | Stores non-sensitive configuration data, creatable via CLI, files, or YAML manifests |
| **Secret** | Securely stores sensitive information such as credentials and keys |
| **Environment Variable Injection** | Method for delivering configuration data into containers |
| **Volume Mount** | Alternative method for delivering configuration data into containers as files |
| **Dynamic Configuration Update** | Updating configuration and restarting applications to pick up changes |
| **Configuration Management Best Practices** | Separating configuration from code for scalable, maintainable applications |

---

## 🏁 Conclusion

In this lab, you have successfully learned how to manage configuration data and secrets in OpenShift. You accomplished the following key tasks:

### 📘 What You Learned

- Created ConfigMaps using multiple methods (command line, from files, and YAML manifests)
- Stored sensitive information securely using OpenShift Secrets
- Injected configuration data into containers as environment variables and mounted volumes
- Updated configuration dynamically and restarted applications to pick up changes
- Applied best practices for configuration management

### 💡 Why This Matters

Configuration management is crucial for building scalable, maintainable applications. By separating configuration from code, you can:

- Deploy the same application across different environments
- Update configuration without rebuilding container images
- Maintain security by properly handling sensitive data
- Enable easier troubleshooting and debugging
- Follow cloud-native best practices

These skills are essential for the Red Hat Certified OpenShift Application Developer exam and for real-world application development in OpenShift environments. The ability to properly manage configuration and secrets is fundamental to building production-ready applications that are secure, scalable, and maintainable.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al_Nafi-Cybersecurity_Training-blue?style=for-the-badge)

</div>
