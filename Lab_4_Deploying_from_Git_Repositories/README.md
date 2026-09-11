<div align="center">

# 🔗 Deploying Applications from Git Repositories with OpenShift

![OpenShift](https://img.shields.io/badge/OpenShift-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Webhooks](https://img.shields.io/badge/Webhooks-EE0000?style=for-the-badge&logo=redhat&logoColor=white)

**Status:** ✅ Completed

</div>

---

## 📑 Table of Contents

- [🔑 Key Concepts](#-key-concepts)
- [🏁 Conclusion](#-conclusion)
  - [✅ Key Achievements](#-key-achievements)
  - [💡 Key Takeaways](#-key-takeaways)

---

## 🔑 Key Concepts

| Concept | Description |
|---|---|
| **`oc new-app`** | Deploys applications directly from Git repository sources |
| **Webhook-Triggered Build** | Automatically deploys an application when code changes are pushed to the repository |
| **Source-to-Image (S2I)** | Enables continuous integration and deployment workflows from source code |
| **Build & Deployment Lifecycle** | Monitoring builds, managing deployment history, and troubleshooting issues |
| **Rollback** | Reverting to a previous version using Git history |

---

## 🏁 Conclusion

In this lab, you have successfully:

### ✅ Key Achievements

- **Linked a Git repository to OpenShift** — You learned how to deploy applications directly from Git repositories using the `oc new-app` command with Git sources
- **Configured automatic deployments** — You set up webhook-triggered builds that automatically deploy your application when code changes are pushed to the repository
- **Implemented CI/CD practices** — You experienced how OpenShift's source-to-image (S2I) process enables continuous integration and deployment workflows
- **Managed build and deployment lifecycle** — You learned to monitor builds, manage deployment history, and troubleshoot common issues

### 💡 Key Takeaways

**Why Git-based deployments matter:**

- **Developer Productivity** — Developers can deploy applications simply by pushing code changes
- **Automation** — Reduces manual deployment steps and human errors
- **Traceability** — Every deployment is tied to a specific Git commit, providing clear audit trails
- **Rollback Capability** — Easy to revert to previous versions using Git history

**Real-World Applications:**

- **Microservices Architecture** — Each service can be deployed independently from its own Git repository
- **Multi-environment Deployments** — Different branches can be deployed to different environments (dev, staging, production)
- **Team Collaboration** — Multiple developers can contribute to the same application with automatic deployments

This knowledge is essential for the Red Hat Certified OpenShift Application Developer exam and provides practical skills for modern DevOps practices in enterprise environments.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al_Nafi-Cybersecurity_Training-blue?style=for-the-badge)

</div>
