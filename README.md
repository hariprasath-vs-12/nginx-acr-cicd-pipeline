# nginx-acr-cicd-pipeline

CI/CD pipeline using GitHub Actions. On every push to `main`, it builds an nginx Docker image, scans it with Trivy, and pushes it to Azure Container Registry (ACR).

## Flow

Push to GitHub → Build image → Trivy scan → Push to ACR

The image is pushed only if the scan passes.

## Tech stack

- GitHub Actions
- Docker + nginx (alpine)
- Trivy (vulnerability scan)
- Azure Container Registry

## Project structure

```
.
├── index.html
├── Dockerfile
└── .github/workflows/acr.yml
```

## Setup

### 1. Create ACR and service principal

```bash
az group create -n rg-acr-demo -l centralindia
az acr create -n myacr12345 -g rg-acr-demo --sku Basic

ACR_ID=$(az acr show -n myacr12345 --query id -o tsv)
az ad sp create-for-rbac -n sp-github-acr --role AcrPush --scopes $ACR_ID
```

### 2. Add GitHub secrets

Repo → Settings → Secrets and variables → Actions

| Secret | Value |
|---|---|
| `ACR_LOGIN_SERVER` | `myacr12345.azurecr.io` |
| `ACR_USERNAME` | service principal `appId` |
| `ACR_PASSWORD` | service principal `password` |

### 3. Push code

```bash
git add .
git commit -m "add pipeline"
git push origin main
```

## Verify

```bash
az acr repository show-tags -n myacr12345 --repository nginx-app -o table
```

## Run locally

```bash
docker build -t nginx-app .
docker run -p 8080:80 nginx-app
```

Open http://localhost:8080

## Cleanup

```bash
az group delete -n rg-acr-demo --yes --no-wait
```

## Notes

- Image tags: commit SHA and `latest`.
- Scan fails on CRITICAL and HIGH issues (unfixed ones are ignored).
- Next step: replace the secret password with OIDC login.
