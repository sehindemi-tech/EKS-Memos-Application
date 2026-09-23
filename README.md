# Kubernetes Memos-Application on AWS EKS
## Tech Stack

![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat-square&logo=amazonaws&logoColor=FF9900)
![Terraform](https://img.shields.io/badge/Terraform-232F3E?style=flat-square&logo=terraform&logoColor=844FBA)
![Kubernetes](https://img.shields.io/badge/Kubernetes-232F3E?style=flat-square&logo=kubernetes&logoColor=326CE5)
![Helm](https://img.shields.io/badge/Helm-232F3E?style=flat-square&logo=helm&logoColor=white)
![Argo CD](https://img.shields.io/badge/Argo%20CD-232F3E?style=flat-square&logo=argo&logoColor=EF7B4D)
![Docker](https://img.shields.io/badge/Docker-232F3E?style=flat-square&logo=docker&logoColor=2496ED)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-232F3E?style=flat-square&logo=githubactions&logoColor=2088FF)
![Traefik](https://img.shields.io/badge/Traefik-232F3E?style=flat-square&logo=traefikproxy&logoColor=24A1C1)
![ExternalDNS](https://img.shields.io/badge/ExternalDNS-232F3E?style=flat-square&logo=amazonroute53&logoColor=8C4FFF)
![cert-manager](https://img.shields.io/badge/cert--manager-232F3E?style=flat-square&logo=letsencrypt&logoColor=003A70)
![External Secrets](https://img.shields.io/badge/External%20Secrets-232F3E?style=flat-square&logo=amazonwebservices&logoColor=FF9900)
![Prometheus](https://img.shields.io/badge/Prometheus-232F3E?style=flat-square&logo=prometheus&logoColor=E6522C)
![Grafana](https://img.shields.io/badge/Grafana-232F3E?style=flat-square&logo=grafana&logoColor=F46800)
![Trivy](https://img.shields.io/badge/Trivy-232F3E?style=flat-square&logo=aqua&logoColor=1904DA)
![OIDC](https://img.shields.io/badge/OIDC-232F3E?style=flat-square&logo=openid&logoColor=F78C40)
![Pre--Commit](https://img.shields.io/badge/Pre--Commit-232F3E?style=flat-square&logo=precommit&logoColor=FAB040)


## Architecture
![alt text](images/Arch-Diag.jpg)

## Table of Contents
* [Tech Stack](#tech-stack)
* [Architecture](#architecture)
* [Overview](#overview)
* [Quick Start](#quickstart)
* [Platform Demo](#platform-demo)

## Overview
A production-patterned AWS EKS platform, built stage by stage and managed through GitOps. It runs Memos, an open source self-hosted note-taking application, backed by RDS PostgreSQL. Infrastructure is provisioned with Terraform, everything inside the cluster is reconciled by Argo CD from this repository.

This project goes beyond deploying an application; it demonstrates how to design cloud infrastructure that is secure, scalable, and repeatable by default. Every layer, from provisioning through application delivery, is defined and managed as code.

The build reflects the architectural decisions that matter in production engineering environments: GitOps-driven deployments, modular and reusable infrastructure, automated secrets management, resilient networking, and security validation integrated throughout the delivery pipeline.

## Quick Start
Want to test the application locally?

**Prerequisites:** Docker installed and running.

This builds the custom multi-stage image used by this project (Node/pnpm frontend, Go backend, `scratch` final stage)

```bash
cd app/memos
docker build -t memos:v1 .
docker run -d \
  --name memos \
  -p 5230:5230 \
  -v ~/.memos/:/var/opt/memos \
  memos:v1
```
Then open ```http://localhost:5230```

Check it's up:

```bash
docker logs memos
```

Stop and remove the container:

```bash
docker stop memos && docker rm memos
```

## Platform Demo

TO-do



## Design Priorities
* **Modular Terraform**, One module per concern (networking, EKS, RDS, security), so a change to one layer doesn't require reasoning about the whole stack, and any module can be redeployed or replaced independently.

* **GitOps via Argo CD**, Git as the single source of truth, every cluster change is version-controlled, auditable, and reproducible from the repo alone, not from memory of what was manually applied.

* **Zero standing credentials.**, EKS Pod Identity for every in-cluster workload, GitHub OIDC for every CI workflow, no long-lived AWS access keys anywhere in the project.

* **Fully automated TLS and DNS**, through cert-manager and ExternalDNS, removing manual certificate issuance or DNS record management entirely; every hostname in the cluster resolves and serves HTTPS without a human ever touching Route 53 or a cert file directly.

* **Recoverability over convenience** Argo CD is deployed and upgraded by Terraform rather than managing itself, so a bad GitOps change can never disable the tool needed to fix it.

* **Least privilege where it matters, deliberate debt where it doesn't.** Fine-grained IAM policies scoped to exact resource ARNs for anything security-sensitive (KMS keys, Secrets Manager entries); broader wildcard actions accepted short-term on lower-risk roles, tracked explicitly rather than left unexamined.

* **Verify against reality, not assumption.** Terraform validation blocks check real AWS API constraints, regex-shaped ARNs, actual enum values, rather than generic non-empty checks; several values were confirmed against live AWS documentation mid-build rather than trusted from memory.

* **Security scanning built into CI, not bolted on after.** Trivy scans both Terraform and the built container image before anything reaches the cluster; Hadolint and TFLint catch structural issues in the Dockerfile and Terraform before they're even planned.


## Architecture Overview

The platform is composed of several layers that work together to automate infrastructure provisioning and application delivery end to end.

### Application
- **Memos image**: Made use of custom multi-stage build: Node/pnpm compiles the frontend, Go compiles the backend and embeds the compiled frontend via go:embed, final stage is scratch running as non-root UID 10001.
- **PostgreSQL database**: RDS-hosted, backs Memos as its sole data store; connection string assembled from the RDS-managed master secret.
- **Docker multi-stage build**:  Separates build tooling from the runtime image, so nothing but the compiled binary and its cert bundle ships in the final container.

### Infrastructure
- **AWS EKS**: The cluster every workload runs on, managed node group with Pod Identity enabled.

- **AWS RDS PostgreSQL**: Private, single-AZ instance backing Memos reachable only from the cluster's security group.

- **AWS VPC**: Two-AZ network the cluster and RDS live in, with public/private subnet split.

- **Security Groups**: Scope RDS access to the cluster SG only, the EKS cluster role's own policy handles NLB provisioning without a separate node-role rule.

- **AWS Secrets Manager**: Stores the RDS master credentials and the monitoring basic-auth credentials, source of truth for everything External Secrets syncs into the cluster.

- **AWS KMS**: Encrypts the Secrets Manager entries at rest, External Secrets' IAM role needed explicit kms:Decrypt to read them.

- **IAM Roles for Pod Identity**: One role per workload (cert-manager, ExternalDNS, External Secrets, EBS CSI), each bound to an exact namespace, service_account pair via aws_eks_pod_identity_association.

- **AWS S3 bucket for Terraform state and locking**: Holds remote state with native S3 locking use_lockfile = true, also used to store the gitignored .tfvars file fetched during CI runs.

- **CloudWatch**: Control-plane logging and general log/metric collection outside the Prometheus stack.

- **IAM**: Underlies every AWS-facing permission in the project: Pod Identity roles, the GitHub OIDC roles, the EKS cluster/node roles.

- **Networking**: The VPC, subnet, and route table layer everything else sits on top of.

- **VPC endpoints**: S3 gateway plus STS/ECR interface endpoints, keeping state access, Pod Identity token exchange, and image pulls off the single NAT Gateway.

- **Route 53**: Hosts the DNS zone, ExternalDNS writes records into it, cert-manager writes and cleans up ACME DNS-01 challenge TXT records here too.

### EKS Infrastructure
- **Helm**: The packaging format every in-cluster component (Traefik, cert-manager, External Secrets, kube-prometheus-stack) is installed through, rendered by Argo CD.

- **Argo CD (app-of-apps)**: The GitOps controller, one root Application discovers and syncs every other Application in the repo(Apps of Apps), in sync-wave order where dependencies require it.

- **ExternalDNS**: Watches Ingress objects and creates the matching Route 53 records automatically; no DNS entry in this project was created by hand.

- **Cert-manager**: Issues and renews TLS certificates via Let's Encrypt, using DNS-01 challenges against Route 53.

- **Traefik Ingress**: Terminates TLS at the edge and routes every hostname to its backend Service, fronted by an NLB the cluster's IAM role provisions automatically.

- **External Secrets Operator**: Pulls credentials from Secrets Manager and materializes them as Kubernetes Secrets, kept in sync on a refresh interval.

### Observability
- **Grafana**: Dashboards for cluster and node metrics, deployed as part of kube-prometheus-stack, protected by its own login.

- **Prometheus**: Scrapes cluster and node metrics via kube-state-metrics and node-exporter; sits behind a Traefik basic-auth Middleware since it has no built-in authentication.

- **CloudWatch**: Separate from the Prometheus stack; covers control-plane logs and any AWS-side signals Prometheus doesn't reach.

### Security
- **Pre-commit hooks**: Run hooks locally to test security,linting, formating before pushing to repository.

- **GitHub OIDC authentication**: Every CI workflow assumes an AWS role via OIDC; no long-lived AWS access keys exist anywhere in the pipeline.

- **Trivy**: Scans both Terraform (IaC) and the built Docker image, uploading SARIF results to GitHub's Security tab; the image scan blocks on CRITICAL findings.

- **Gitleaks**: Checks our local repository if any secrets has been leaked before been pushed to the remote repository.

- **Hadolint**: Lints the Dockerfile before it's built in CI.

- **TFLint**: Lints Terraform code as part of the plan workflow..


## GitOps Workflow

## CICD Pipeline

## Observablity

## Security

## Key Technical Decisions

## Known Limitations and Future Improvements

## Repository layout
```
.
├── .github/workflows/   - Terraform plan/apply/destroy, image build and push
├── app/                 - Memos source, Dockerfile and DockerCompose file
├── bootstrap/           - State bucket, ECR, KMS, GitHub OIDC provider and roles
└── infra/
    ├── terraform/
    │   ├── env/dev/     - Root configuration, backend, module calls
    │   └── modules/     - networking, security, eks, rds, logging, route-53
    └── kubernetes/
        ├── argo-cd/
        │   ├── root.yml  - App-of-apps applied manually once
        │   └── apps/     - One Argo CD Application per component
        ├── values/       - Value overlays for third-party charts only
        ├── manifests/    - In-house cluster config, plain YAML (no chart)
        ├── monitoring/   - Monitoring ingress, middleware and ExternalSecrets
        └── my-chart/memo-app/  - Memos Helm chart
```