# 🚀 Serverless Strapi Deployment (ECS Fargate)
**Automated Container Orchestration with GitHub Actions & Terraform**

---
## 📋 Project Overview
This repository contains a fully automated **ECS Fargate** pipeline for deploying a Strapi Headless CMS. By using Fargate, we eliminated the need to manage EC2 instances, moving to a modern serverless architecture.

| Component | Technology |
| :--- | :--- |
| **Orchestration** | AWS ECS Fargate |
| **Registry** | Amazon ECR (`811738710312`) |
| **IaC** | Terraform (v15 Sync) |
| **CI/CD** | GitHub Actions |

---
## 📺 Demo & Walkthrough
[![Watch the Demo](https://cdn.loom.com/sessions/thumbnails/b9cdaa3c449c49848bd5e176f6ab4b28-00001.jpg)](https://www.loom.com/share/b9cdaa3c449c49848bd5e176f6ab4b28)

---
## ⚙️ Automation Workflow
1. **Container Management:** Existing local images are tagged and pushed to ECR to resolve the `CannotPullContainerError`.
2. **Infrastructure:** Terraform uses dynamic data sources to auto-discover VPC and public subnets for the v15 service.
3. **Resource Scaling:** Task definition set to **1024 CPU** and **2048 Memory** to accommodate the 3.8GB image overhead.

---
## ✅ Deployment Status
* **Cluster:** `strapi-cluster-task8` is **Active**.
* **Service:** `strapi-service-v15` is deployed with 1 running task.
* **Database:** RDS PostgreSQL 16 is connected via `strapi-db-subnet-group-v15`.
* **Network:** Successfully deployed in us-east-1 with public access on port `1337`.
