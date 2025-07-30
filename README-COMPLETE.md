## Application Details

**Language:**  C# 
**Framework:** .NET 6.0 (ASP.NET Core MVC) 
**Dependencies:** Microsoft.AspNetCore.Mvc
Microsoft.Extensions.Diagnostics.HealthChecks
Microsoft.EntityFrameworkCore (with Sqlite)
Microsoft.AspNetCore.Identity

**Application files:** WebGoatCore.sln (solution file)
WebGoatCore/ (main application)
MyWebApp/ (additional app, if used)
MyWebApp.UnitTests/,
WebGoatCore.UnitTests/ (unit tests)

---

## Template 1: Secure Dockerfile Creation

**Prompt Template:**
Create a secure Dockerfile with no vulnerabilities for an existing .NET application.

**Requirements:**
- Use specific base image versions (not latest)
- Implement non-root user execution
- Add security contexts and health checks
- Include dependency vulnerability fixes
- Follow security best practices
- Create .dockerignore file

Application Details

**Language:**  C# 
**Framework:** .NET 6.0 (ASP.NET Core MVC) 
**Dependencies:** Microsoft.AspNetCore.Mvc
Microsoft.Extensions.Diagnostics.HealthChecks
Microsoft.EntityFrameworkCore (with Sqlite)
Microsoft.AspNetCore.Identity

**Application files:** WebGoatCore.sln (solution file)
WebGoatCore/ (main application)
MyWebApp/ (additional app, if used)
MyWebApp.UnitTests/,
WebGoatCore.UnitTests/ (unit tests)

---

## Template 2: Kubernetes Deployment Files

**Prompt Template:**
Create Kubernetes deployment files with security best practices for .NET application.

**Requirements:**
- Create Deployment and Service objects
- Use ClusterIP as service type
- Implement security contexts and network policies
- Add ConfigMap for environment variables
- Include resource limits and health checks
- Use namespace: .NET-app-namespace

**Application details:**
- Container image: .NET-app
- Port: 8080
- Replicas: 3
- Environment: production

---

## Template 3: CI/CD Pipeline with Trivy Integration

**Prompt Template:**
Create a GitHub Actions workflow file with security scanning for a .NET application.

**Requirements:**
- Two jobs: build and deploy
- Deploy to AKS cluster
- Use build ID as image tag
- Deploy to existing namespace: .NET-app-namespace
- Integrate Trivy security scanning with these specifications:
  - Install Trivy manually
  - Use aquasecurity/trivy-action@0.28.0
  - Format: table and SARIF
  - Exit code: 1 for critical/high vulnerabilities
  - Ignore unfixed vulnerabilities
  - Severity: CRITICAL,HIGH

**Pipeline details:**
- Platform: GitHub Actions
- Container registry: Azure Container Registry
- Deployment target: Azure Kubernetes Service
- Triggers: push to main/develop, PR to main
## Application Details

**Language:**  C# 
**Framework:** .NET 6.0 (ASP.NET Core MVC) 
**Dependencies:** Microsoft.AspNetCore.Mvc
Microsoft.Extensions.Diagnostics.HealthChecks
Microsoft.EntityFrameworkCore (with Sqlite)
Microsoft.AspNetCore.Identity

**Application files:** WebGoatCore.sln (solution file)
WebGoatCore/ (main application)
MyWebApp/ (additional app, if used)
MyWebApp.UnitTests/,
WebGoatCore.UnitTests/ (unit tests)

---

## Template 1: Secure Dockerfile Creation

**Prompt Template:**
Create a secure Dockerfile with no vulnerabilities for an existing .NET application.

**Requirements:**
- Use specific base image versions (not latest)
- Implement non-root user execution
- Add security contexts and health checks
- Include dependency vulnerability fixes
- Follow security best practices
- Create .dockerignore file

Application Details

**Language:**  C# 
**Framework:** .NET 6.0 (ASP.NET Core MVC) 
**Dependencies:** Microsoft.AspNetCore.Mvc
Microsoft.Extensions.Diagnostics.HealthChecks
Microsoft.EntityFrameworkCore (with Sqlite)
Microsoft.AspNetCore.Identity

**Application files:** WebGoatCore.sln (solution file)
WebGoatCore/ (main application)
MyWebApp/ (additional app, if used)
MyWebApp.UnitTests/,
WebGoatCore.UnitTests/ (unit tests)

---

## Template 2: Kubernetes Deployment Files

**Prompt Template:**
Create Kubernetes deployment files with security best practices for .NET application.

**Requirements:**
- Create Deployment and Service objects
- Use ClusterIP as service type
- Implement security contexts and network policies
- Add ConfigMap for environment variables
- Include resource limits and health checks
- Use namespace: .NET-app-namespace

**Application details:**
- Container image: .NET-app
- Port: 8080
- Replicas: 3
- Environment: production

---

## Template 3: CI/CD Pipeline with Trivy Integration

**Prompt Template:**
Create a GitHub Actions workflow file with security scanning for a .NET application.

**Requirements:**
- Two jobs: build and deploy
- Deploy to AKS cluster
- Use build ID as image tag
- Deploy to existing namespace: .NET-app-namespace
- Integrate Trivy security scanning with these specifications:
  - Install Trivy manually
  - Use aquasecurity/trivy-action@0.28.0
  - Format: table and SARIF
  - Exit code: 1 for critical/high vulnerabilities
  - Ignore unfixed vulnerabilities
  - Severity: CRITICAL,HIGH

**Pipeline details:**
- Platform: GitHub Actions
- Container registry: Azure Container Registry
- Deployment target: Azure Kubernetes Service
- Triggers: push to main/develop, PR to main

Please put this information in readme file. ONly this info should be there
