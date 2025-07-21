# 🛡️ Secure .NET WebGoat Application - DevSecOps Pipeline

## 📋 Overview

This repository contains a secure .NET 5.0 ASP.NET Core application (WebGoat Core) with comprehensive DevSecOps practices implemented through Docker containerization, Kubernetes deployment, and GitHub Actions CI/CD with security scanning.

## 🏗️ Application Architecture

**Framework:** ASP.NET Core 5.0  
**Database:** SQLite (NORTHWND.sqlite)  
**Authentication:** ASP.NET Core Identity  
**Security:** OWASP WebGoat Core training application  

### Key Components
- **Controllers:** Account, Blog, Cart, Checkout, Home, Product, StatusCode
- **Models:** Customer, Product, Order, Cart, Category, Supplier, etc.
- **Data Access:** Entity Framework Core with Repository pattern
- **Utilities:** Email sender, LINQ extensions, session management

## 🚀 CI/CD Pipeline Options

### Option 1: Standard Workflow (Recommended)
**File:** `.github/workflows/build-deploy.yml`
- Uses `azure/login@v1` action
- Requires `AZURE_CREDENTIALS` JSON secret
- Streamlined authentication

### Option 2: Alternative Workflow
**File:** `.github/workflows/build-deploy-alternative.yml`
- Uses Azure CLI login directly
- Requires individual secrets (`AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, etc.)
- More granular control

## 🔧 Quick Setup

### 1. Configure GitHub Secrets
See [SETUP-SECRETS.md](./SETUP-SECRETS.md) for detailed instructions.

**Required secrets:**
```
AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID
REGISTRY_LOGIN_SERVER, AKS_RESOURCE_GROUP, AKS_CLUSTER_NAME
```

### 2. Deploy Infrastructure
```bash
# Create Azure resources
az group create --name myResourceGroup --location eastus
az acr create --resource-group myResourceGroup --name myregistry --sku Standard
az aks create --resource-group myResourceGroup --name myAKSCluster --node-count 3
```

### 3. Activate Pipeline
- Push to `main` or `develop` branch
- Or trigger manually via GitHub Actions

## 🛡️ Security Features

### Docker Security
- ✅ Multi-stage builds
- ✅ Non-root user (UID 1001)
- ✅ Read-only root filesystem
- ✅ Minimal base images
- ✅ No package managers in runtime

### Kubernetes Security
- ✅ Pod Security Contexts
- ✅ Network Policies
- ✅ RBAC Configuration
- ✅ Resource Limits
- ✅ Health Checks
- ✅ Namespace Isolation

### CI/CD Security
- ✅ Trivy vulnerability scanning
- ✅ SARIF integration
- ✅ Security artifact uploads
- ✅ Fail on critical vulnerabilities
- ✅ Multi-format scan reports

## 📁 Project Structure

```
├── .github/workflows/          # CI/CD pipelines
├── k8s/                       # Kubernetes manifests
├── docker/                    # Docker configurations
├── WebGoatCore/               # Main application
│   ├── Controllers/
│   ├── Models/
│   ├── Data/
│   ├── Utils/
│   └── ViewModels/
├── WebGoatCore.UnitTests/     # Unit tests
├── Dockerfile                 # Multi-stage container build
└── README.md
```

## 🔄 Pipeline Workflow

1. **Code Push** → Triggers CI/CD
2. **Build** → Docker image creation
3. **Security Scan** → Trivy vulnerability assessment
4. **Registry Push** → Azure Container Registry
5. **Deploy** → Azure Kubernetes Service
6. **Health Check** → Application readiness verification

## 📊 Monitoring & Observability

- Health check endpoints at `/health` and `/health/ready`
- Kubernetes readiness and liveness probes
- Resource monitoring via Azure Monitor
- Security scan results in GitHub Security tab

## 🚨 Security Scanning Results

The pipeline includes comprehensive security scanning:
- **Format:** SARIF, JSON, Table
- **Severity:** Critical, High vulnerabilities
- **Integration:** GitHub Security tab
- **Artifacts:** 30-day retention of scan results

## 🎯 Deployment Environments

- **Production:** `main` branch
- **Development:** `develop` branch
- **Manual:** Workflow dispatch trigger

## 🔧 Local Development

```bash
# Build and run locally
dotnet restore WebGoatCore/WebGoatCore.csproj
dotnet run --project WebGoatCore/WebGoatCore.csproj

# Build Docker image
docker build -t webgoat-core:local .
docker run -p 8080:8080 webgoat-core:local
```

## 📞 Support

For issues and questions:
1. Check [SETUP-SECRETS.md](./SETUP-SECRETS.md) for configuration help
2. Review GitHub Actions logs for pipeline issues
3. Verify Azure resource permissions
4. Check Kubernetes cluster connectivity

## 🏷️ Version Information

- **.NET Version:** 5.0.17
- **ASP.NET Core:** 5.0.17
- **Docker Base:** mcr.microsoft.com/dotnet/aspnet:5.0.17-alpine3.16
- **Kubernetes:** 1.28+
- **Azure CLI:** Latest

---

**Built with ❤️ for secure DevSecOps practices**
