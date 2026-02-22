# Enterprise Strapi Deployment on AWS ECS Fargate

This repository contains the infrastructure as code (IaC) and CI/CD pipelines required to deploy a highly available, secure, and containerized instance of the Strapi Headless CMS on AWS. 

## 🏗️ Architecture Overview

The infrastructure is built using **Terraform** with a modular design, ensuring separation of concerns and security best practices.

* **Networking (`modules/networking`)**: Utilizes a custom AWS VPC with isolated Public and Private subnets. Includes a NAT Gateway to allow private containers to pull updates securely.
* **Security (`modules/security`)**: Implements a strict "Chain of Trust" using AWS Security Groups. The internet can only access the Load Balancer, the Load Balancer can only access the ECS App, and the ECS App can only access the Database.
* **Application Load Balancer (`modules/alb`)**: Acts as the public front door, catching internet traffic on Port 80 and routing it securely to the private Fargate tasks.
* **Compute (`modules/ecs`)**: Runs the Strapi Docker container (3.8GB) on AWS ECS Fargate (Serverless Compute) with 1024 CPU and 2048 Memory. Fargate tasks are deployed in private subnets with public IPs disabled.
* **Database (`modules/rds`)**: Provisions a PostgreSQL 16 database instance inside a private subnet group, making it completely inaccessible from the public internet.

## 📂 Project Structure

```text
.
├── .github/
│   └── workflows/
│       ├── ci.yml               # Builds Docker image and pushes to Amazon ECR
│       └── cd.yml               # Deploys Infrastructure via Terraform
├── modules/
│   ├── alb/                     # Application Load Balancer & Target Groups
│   ├── ecs/                     # Fargate Cluster, Task Defs, & Services
│   ├── networking/              # VPC, Subnets, IGW, NAT, Route Tables
│   ├── rds/                     # PostgreSQL Database
│   └── security/                # Security Groups & Rules
├── src/                         # Strapi Application Source Code
├── Dockerfile                   # Instructions for building the Strapi image
├── main.tf                      # Root Terraform file tying modules together
├── outputs.tf                   # Outputs the final Strapi Admin URL
└── variables.tf                 # Global environment variables
🚀 CI/CD Automation
This project uses GitHub Actions to fully automate the deployment process, separated into two distinct pipelines:

Continuous Integration (CI): Triggered when application code (src/, Dockerfile, package.json) is modified. It builds the Strapi Docker image and securely pushes it to Amazon ECR.

Continuous Deployment (CD): Triggered when infrastructure code (.tf files) is modified. It validates, plans, and applies the Terraform modules to provision the AWS environment.

Required GitHub Secrets
To run these pipelines, the following secrets must be configured in the GitHub repository:

AWS_ACCESS_KEY_ID: Your AWS IAM user access key.

AWS_SECRET_ACCESS_KEY: Your AWS IAM user secret key.

🛠️ Local Development & Deployment
Prerequisites
Terraform (v1.5.0+)

AWS CLI configured with appropriate credentials

Docker

Manual Infrastructure Deployment
If you need to deploy the infrastructure manually from your local machine, run the following commands from the root directory:

Bash
# Initialize Terraform and download modules
terraform init

# Review the deployment plan
terraform plan

# Apply the configuration
terraform apply -auto-approve
