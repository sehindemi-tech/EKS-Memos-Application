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
* [Design Priorities](#design-priorities)
* [Architecture Overview](#architecture-overview)


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

### Bootstrap Infrastructure

The infrastructure is intentionally divided into two Terraform layers: bootstrap and infra.

The bootstrap layer creates resources that must already exist before the infrastructure can be deployed, including:

- Terraform remote state storage (S3, with native state locking)
- Amazon ECR
- GitHub OIDC authentication (provider and roles)

Separating bootstrap resources from workload infrastructure avoids a circular dependency: the main configuration's S3 backend can't exist until the bucket itself has been created by something else first. Managing these foundational resources as code, rather than clicking them into existence once by hand, keeps the platform reproducible from a clean AWS account.

**Why this matters**

Bootstrap resources rarely change and rarely need to be destroyed alongside everything else; keeping them in a separate state means a full terraform destroy of the main infrastructure doesn't take the state bucket or OIDC trust out from under itself.

### Modular Terraform

Rather than one large configuration, the project is organised into modules by concern:

- Networking (VPC, subnets, NAT, VPC endpoints)
- EKS (cluster, node group, add-ons, access entries)
- RDS
- Security (security groups)
- Pod Identity

**Why this matters**

A change to one layer, such as resizing the node group or adjusting an RDS parameter, doesn't require reasoning about the whole stack, and each module can be planned or reasoned about independently.

### Container Build (Docker)

Memos is built using a multi-stage Docker build that separates frontend and backend compilation from the final runtime image.

The build process:

- Compiles the Vite/TypeScript frontend with Node and pnpm.

- Compiles the Go backend, with the frontend embedded into the binary via go:embed.
- Final stage is using scratch, containing only the compiled binary and its TLS certificate bundle.
- Runs as a non-root user (UID 10001).

**Why this matters**

- Smaller deployment artifact; no OS, no package manager, no shell.

- Reduced attack surface; there is nothing in the image an attacker could use beyond the application itself.

- go:embed removes the need to ship or mount frontend assets separately from the binary that serves them.

### Kubernetes Platform

Amazon EKS is the orchestration platform. Supporting components provide ingress, certificate management, DNS automation, secret synchronisation, monitoring, and GitOps deployment:

- Traefik (ingress)
- cert-manager
- ExternalDNS
- External Secrets Operator
- kube-prometheus-stack (Prometheus, Grafana)
- Argo CD

Rather than installing each component by hand, every one of them is deployed and reconciled declaratively through Argo CD, so the cluster's running state can be reproduced from Git.

**Why this matters**

Each component has one clear responsibility. Ingress, TLS, DNS, and secrets are handled by separate, independently replaceable tools rather than one monolithic layer, which keeps the failure surface of any single incident contained to the component that owns it.

### Helm & GitOps with Argo CD

Third-party components (Traefik, cert-manager, ExternalDNS, External Secrets, kube-prometheus-stack) are deployed as Helm charts with a values overlay from this repository. Memos is packaged as its own custom Helm chart, managing:

- Deployment
- Service
- Ingress
- ExternalSecret (database DSN)

Every Application is configured with:

- Automated synchronisation
- Self-healing (drift introduced outside Git is reverted automatically)
- Automatic pruning of resources removed from Git

**Why this matters**

Git becomes the single source of truth. A kubectl edit against a live resource doesn't stick; Argo CD reverts it on the next reconciliation pass. Every change to the cluster's state has a corresponding commit.

### App of Apps(Argo CD)
- A single root Application, applied once and manually via kubectl apply, is the only object ever applied directly to the cluster
- The root Application points at argo-cd/apps/ in this repo; Argo CD discovers every file there and manages each one as its own child Application, syncing continuously with no further manual intervention

- Child Applications fall into three shapes: third-party Helm charts with a values overlay from values/, plain manifests with no upstream chart from infrastructure/, and the Memos chart in my-chart/
- prune: true and selfHeal: true are set on every Application, so removing a file from Git deletes the resource, and manual drift on a live resource gets reverted automatically

> **Note**
> Dependencies between Applications are ordered with sync waves rather than left implicit. The ClusterIssuer Application waits for cert-manager's CRDs to exist; the ClusterSecretStore Application waits for External Secrets' CRDs. Without this, an Application can fail its first sync simply because the CRD it depends on hasn't landed yet.

**Why this matters**
Every component in the cluster, from Traefik to Memos itself, is added by committing a file, not by running a command against the cluster. A full rebuild only ever needs one manual step; everything after that is Argo CD reading the same repo a human would read.

### Secrets Management

Sensitive configuration is never committed to Git and never stored in plaintext in Terraform state.

- RDS database credentials are generated and stored by AWS using manage_master_user_password, encrypted with a KMS key.

- External Secrets Operator retrieves credentials from Secrets Manager and materialises them as Kubernetes Secrets.

- Deployments consume secrets through environment variables sourced from those Secrets.

- Access from External Secrets' IAM role to the KMS key and Secrets Manager entry is scoped to the specific secret ARN, not the account's secrets broadly

**Why this matters**

The database password never appears in a .tf file, a terraform plan diff, or a Kubernetes manifest it's generated by AWS, read by a scoped IAM role, and synced automatically.


### Security

Security was built in throughout rather than added afterwards:

- GitHub OIDC authentication, no long-lived AWS credentials anywhere in CI.

- IAM Pod Identity scoped per workload, per (namespace, service_account) pair.

- KMS encryption on Secrets Manager entries.

- Dockerfile linting (Hadolint).

- Container image scanning (Trivy, CRITICAL findings block the pipeline).

- Infrastructure-as-code scanning (Trivy).

- Private, non-publicly-accessible RDS instance.

- Automatic HTTPS certificates via cert-manager, with automated renewal.

- Non-root application container (UID 10001, runAsNonRoot enforced).

- Secret scanning before commits reach the remote repository (Gitleaks).

- Local pre-commit hooks running the same checks before a push.

**Why this matters**

These controls catch problems before they reach the cluster rather than after; a leaked secret is caught locally, a vulnerable image is caught in CI, and a compromised build pipeline has no path to infrastructure because it authenticates through a separate, narrowly scoped OIDC role from the one Terraform uses.

### CI/CD Pipeline

GitHub Actions automates delivery:

- Terraform: format check, TFLint, validate, and a Trivy IaC scan, with the plan posted as a PR comment

- Apply on merge to main destroy is manual-dispatch only, gated behind a typed confirmation

- Docker: Hadolint, build with layer caching, Trivy image scan, push to ECR tagged by commit SHA

- The build workflow commits the new image tag and digest back into the Memos chart's values.yaml, which Argo CD then picks up and syncs automatically

- Authentication to AWS throughout is via GitHub's OIDC integration, using separate roles for the Terraform and image-build workflows

**Why this matters**

There is no manual deployment step anywhere in this pipeline. A merge to mai` is the only action a human takes, everything from validation through to the running pod is automated and auditable from the commit history.

## Known Limitations and Future Improvements

### Known Limitations

- **t3.small node instance type caps pod density at 11 per node.** Four unavoidable per-node system DaemonSets already eat into that before any real workload gets scheduled. This caused an actual incident: a DaemonSet pod sat Pending indefinitely because it was pinned to one specific node that was already full.

- **Spot instances carry interruption risk for stateful workloads.** A Spot interruption took a node NotReady while it happened to be hosting external-secrets-webhook, which briefly broke every ExternalSecret operation cluster-wide until it rescheduled.

- **Single NAT Gateway is a cost decision, not a resilience one.** All three AZs route their egress through it, so an outage in its AZ takes down egress for the whole cluster. VPC endpoints for S3, STS, and ECR reduce reliance on it but don't remove the risk.

- **RDS runs single-AZ, not Multi-AZ.** No automatic failover if that AZ has a problem.

- **The RDS endpoint is hardcoded in the ExternalSecret's DSN template rather than pulled from Secrets Manager.** The RDS-managed secret only stores username and password, not connection details.

- **Wildcard IAM actions are still on the Terraform OIDC role** (iam:*, ec2:*). Accepted as deliberate short-term debt, narrowing hasn't happened yet.

- **No multi-environment separation yet.** The pipeline is scaffolded for staging/prod but only runs against dev right now.

- **No SSM access on worker nodes**, so a node-level failure like the unexplained Spot NotReady incident can't be investigated at the kubelet level.

- **Node scaling is manual.** Capacity issues during this project were resolved by adding nodes by hand rather than the cluster reacting on its own via karpenter.


### Future Improvements

- Right-size resource requests and limits using real Prometheus data instead of the estimates currently in place.

- Add LimitRange and ResourceQuota per namespace, neither of which exist yet.

- Build out NetworkPolicies, default-deny per namespace with explicit allows for the ingress path, Memos to RDS, and DNS. Right now the pod network is wide open.

- Move Pod Security Standards from nothing to baseline, then tighten toward restricted, starting with Memos since it already runs non-root.

- Add PodDisruptionBudgets for Traefik and cert-manager, and spread Traefik across AZs with topologySpreadConstraints. There's currently no guarantee against losing every ingress replica to a single AZ.

- Rebalance the node group across AZs. It's currently skewed, which makes any AZ-pinned PVC a single point of failure.

- Narrow the wildcard IAM actions on the Terraform role down to what each workflow actually needs.

- Replace the manually-scaled managed node group with Karpenter, so the cluster provisions and right-sizes nodes automatically based on actual pending pod requirements. This would directly solve the t3.small pod density problem this project hit, since Karpenter can pick an appropriately sized instance per workload rather than committing to one instance type for the whole node group up front.

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