# WebGoat Core - Secure .NET Application

A comprehensive security-focused .NET Core application with Docker containerization, Kubernetes deployment, and CI/CD pipeline implementation.

## 🏗️ Architecture Overview

This repository contains a complete enterprise-ready .NET application with:

- **WebGoat Core**: Main ASP.NET Core 5.0 application with security training scenarios
- **Docker Security**: Hardened multi-stage Dockerfile with security best practices
- **Kubernetes Deployment**: Comprehensive K8s manifests with security policies
- **CI/CD Pipeline**: GitHub Actions workflow with Trivy security scanning

## 📁 Repository Structure

```
├── WebGoatCore/                    # Main .NET application
│   ├── Controllers/                # MVC Controllers + Health endpoints
│   ├── Data/                      # Entity Framework repositories
│   ├── Models/                    # Domain models
│   ├── ViewModels/               # View models
│   ├── Utils/                    # Utility classes
│   ├── Exceptions/               # Custom exceptions
│   ├── wwwroot/                  # Static web assets
│   └── WebGoatCore.csproj        # Project file
├── MyWebApp/                      # Secondary web application
├── *UnitTests/                   # Unit test projects
├── docker/                       # Docker configuration and scripts
│   ├── README.md                 # Docker documentation
│   ├── docker-compose.security.yml # Secure compose configuration
│   └── build-secure.sh           # Automated build script
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml            # Namespace definition
│   ├── deployment.yaml           # Application deployment
│   ├── service.yaml              # ClusterIP services
│   ├── configmap.yaml            # Configuration management
│   ├── secrets.yaml              # Secrets management
│   ├── rbac.yaml                 # Role-based access control
│   ├── network-policy.yaml       # Network security policies
│   ├── scaling.yaml              # HPA and PDB configuration
│   ├── deploy.sh                 # Deployment script (Linux)
│   ├── deploy.bat                # Deployment script (Windows)
│   └── README.md                 # Kubernetes documentation
├── .github/workflows/            # GitHub Actions CI/CD
│   ├── build-deploy.yml          # Main CI/CD pipeline
│   ├── security-scan.yml         # Scheduled security scanning
│   └── README.md                 # Pipeline documentation
├── Dockerfile                    # Secure multi-stage container build
├── .dockerignore                 # Docker build context exclusions
└── README.md                     # This file
```

## 🔒 Security Features

### **Container Security**
- ✅ Multi-stage Docker build with minimal attack surface
- ✅ Non-root user execution (UID 1001)
- ✅ Read-only root filesystem
- ✅ Dropped Linux capabilities
- ✅ Security contexts and health checks

### **Kubernetes Security**
- ✅ Pod Security Standards implementation
- ✅ Network policies with default deny-all
- ✅ RBAC with minimal permissions
- ✅ Resource limits and quotas
- ✅ Security contexts at pod and container level

### **CI/CD Security**
- ✅ Trivy vulnerability scanning
- ✅ SARIF integration with GitHub Security tab
- ✅ Pipeline fails on critical/high vulnerabilities
- ✅ Automated security reporting

## 🚀 Technology Stack

- **Language**: C#
- **Framework**: ASP.NET Core 5.0
- **Database**: SQLite (NORTHWND.sqlite)
- **Authentication**: ASP.NET Core Identity
- **ORM**: Entity Framework Core 5.0
- **Container**: Docker with multi-stage builds
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions
- **Security Scanning**: Trivy

## 🏃 Quick Start

### **Local Development**
```bash
# Clone the repository
git clone https://github.com/Ananyakg1/.Net-application.git
cd .Net-application

# Build and run with Docker
docker build -t webgoat-core:local .
docker run -p 8080:8080 webgoat-core:local

# Access the application
# http://localhost:8080
```

### **Kubernetes Deployment**
```bash
# Deploy to Kubernetes cluster
cd k8s
./deploy.sh production

# Or on Windows
deploy.bat production

# Verify deployment
kubectl get all -n dotnet-namespace
```

### **CI/CD Pipeline Setup**

1. **Configure GitHub Secrets** (Required for pipeline):
   ```
   AZURE_CLIENT_ID
   AZURE_CLIENT_SECRET
   AZURE_SUBSCRIPTION_ID
   AZURE_TENANT_ID
   REGISTRY_LOGIN_SERVER
   REGISTRY_USERNAME
   REGISTRY_PASSWORD
   AKS_CLUSTER_NAME
   AKS_RESOURCE_GROUP
   ```

2. **Trigger Pipeline**:
   - Push to `main` or `develop` branches
   - Create PR to `main` branch
   - Manual workflow dispatch

## 📊 Key Dependencies

### **Core Framework**
- Microsoft.AspNetCore.Identity.EntityFrameworkCore (5.0.0)
- Microsoft.EntityFrameworkCore.SQLite (5.0.0)
- Microsoft.AspNetCore.Identity.UI (5.0.0)

### **Security & Utils**
- System.Data.SqlClient (4.8.2)
- Json.Net (1.0.23)
- System.Text.Encodings.Web (5.0.1)

## 🔧 Configuration

### **Environment Variables**
```bash
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://+:8080
DOTNET_RUNNING_IN_CONTAINER=true
```

### **Health Check Endpoints**
- `GET /health` - Liveness probe
- `GET /health/ready` - Readiness probe
- `GET /health/startup` - Startup probe
- `GET /health/detailed` - Comprehensive health info

## 🛡️ Security Best Practices Implemented

### **Application Level**
- Secure coding practices
- Input validation and sanitization
- Authentication and authorization
- Security headers configuration

### **Container Level**
- Minimal base images with specific versions
- Non-root user execution
- Read-only filesystems
- Capability restrictions

### **Kubernetes Level**
- Network segmentation
- Pod security standards
- Resource quotas and limits
- RBAC implementation

### **Pipeline Level**
- Vulnerability scanning with Trivy
- Security gate enforcement
- Automated security reporting
- SARIF integration

## 📈 Monitoring & Observability

### **Health Monitoring**
- Kubernetes health probes
- Application health endpoints
- Resource utilization monitoring

### **Security Monitoring**
- Daily vulnerability scans
- GitHub Security tab integration
- Automated issue creation for critical vulnerabilities

## 🔍 Security Scanning

The project includes comprehensive security scanning:

- **Container Scanning**: Trivy scans for OS and application vulnerabilities
- **Dependency Scanning**: NuGet package vulnerability detection
- **Configuration Scanning**: Kubernetes manifest security validation
- **Pipeline Security**: CI/CD pipeline security best practices

## 📝 Documentation

- **Docker**: See `docker/README.md` for container documentation
- **Kubernetes**: See `k8s/README.md` for deployment guides
- **CI/CD**: See `.github/workflows/README.md` for pipeline details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Links

- **GitHub Repository**: https://github.com/Ananyakg1/.Net-application
- **Docker Hub**: (Configure as needed)
- **Documentation**: See individual README files in subdirectories

## 🆘 Support

For issues and questions:
1. Check the documentation in respective subdirectories
2. Review GitHub Issues
3. Create a new issue with detailed description

---

**Note**: This is a security-focused educational application. Some configurations are intentionally vulnerable for training purposes. Do not use in production without proper security reviews.
