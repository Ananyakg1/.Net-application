# Docker Security Best Practices Documentation

This directory contains Docker configurations with comprehensive security hardening for the WebGoat Core .NET application.

## 📁 Files Overview

| File | Description |
|------|-------------|
| `Dockerfile` | Multi-stage secure container build |
| `.dockerignore` | Security-focused build context exclusions |
| `docker-compose.security.yml` | Secure compose configuration |
| `HealthController.cs` | Health check endpoints implementation |

## 🔒 Security Features Implemented

### **Base Image Security**
- ✅ **Specific Versions**: Uses .NET 5.0.17 (no `latest` tags)
- ✅ **Minimal Base Image**: Uses `mcr.microsoft.com/dotnet/aspnet` runtime
- ✅ **Security Updates**: Automatic security updates during build
- ✅ **Multi-stage Build**: Reduces attack surface and image size

### **User & Permission Security**
- ✅ **Non-root Execution**: Runs as UID 1001 (appuser)
- ✅ **Proper File Permissions**: Read-only application files
- ✅ **Directory Security**: Writable directories with restricted access
- ✅ **User Isolation**: Dedicated application user with no shell access

### **Runtime Security**
- ✅ **Signal Handling**: Uses `dumb-init` for proper process management
- ✅ **Environment Hardening**: Disabled diagnostics and debugging
- ✅ **Resource Limits**: CPU and memory constraints via Docker
- ✅ **Health Checks**: Comprehensive health monitoring

### **Network Security**
- ✅ **Non-privileged Port**: Uses port 8080 (>1024)
- ✅ **Minimal Exposure**: Only necessary ports exposed
- ✅ **Header Security**: Configured for reverse proxy use

### **Build Security**
- ✅ **Layer Optimization**: Minimized layers and attack surface
- ✅ **Secret Management**: No secrets in image layers
- ✅ **Dependency Scanning**: NuGet package verification
- ✅ **Clean Build**: Removed debug symbols and unnecessary files

## 🚀 Application Details

### **Technology Stack**
- **Language**: C#
- **Framework**: ASP.NET Core 5.0
- **Runtime**: .NET 5.0.17
- **Database**: SQLite (NORTHWND.sqlite)

### **Key Dependencies**
- Microsoft.AspNetCore.Identity.EntityFrameworkCore (5.0.0)
- Microsoft.EntityFrameworkCore.SQLite (5.0.0)
- Microsoft.AspNetCore.Identity.UI (5.0.0)
- System.Data.SqlClient (4.8.2)
- Json.Net (1.0.23)

### **Application Structure**
```
WebGoatCore/
├── Controllers/          # MVC Controllers + HealthController
├── Data/                # Entity Framework repositories
├── Models/              # Domain models
├── ViewModels/          # View models
├── Utils/               # Utility classes
├── Exceptions/          # Custom exceptions
├── wwwroot/            # Static web assets
└── NORTHWND.sqlite     # SQLite database
```

## 🔧 Build Instructions

### **Basic Build**
```bash
# Build the Docker image
docker build -t webgoat-core:secure .

# Run with security settings
docker run -d \
  --name webgoat-core \
  --user 1001:1001 \
  --read-only \
  --tmpfs /tmp:noexec,nosuid,size=100m \
  --tmpfs /app/logs:noexec,nosuid,size=100m \
  --security-opt no-new-privileges:true \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  -p 8080:8080 \
  webgoat-core:secure
```

### **Production Build with Security**
```bash
# Build with build arguments
docker build \
  --build-arg DOTNET_VERSION=5.0.17 \
  --build-arg ASPNET_VERSION=5.0.17 \
  --build-arg BUILD_CONFIGURATION=Release \
  --build-arg APP_USER_UID=1001 \
  --build-arg APP_USER_GID=1001 \
  -t webgoat-core:v1.0.0 .

# Run with full security hardening
docker run -d \
  --name webgoat-core-prod \
  --user 1001:1001 \
  --read-only \
  --tmpfs /tmp:noexec,nosuid,size=100m \
  --tmpfs /app/logs:noexec,nosuid,size=100m \
  --tmpfs /app/temp:noexec,nosuid,size=50m \
  --security-opt no-new-privileges:true \
  --security-opt seccomp=default \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --memory 512m \
  --cpus 0.5 \
  --restart unless-stopped \
  --health-cmd="curl -f http://localhost:8080/health || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ASPNETCORE_URLS=http://+:8080 \
  -p 8080:8080 \
  webgoat-core:v1.0.0
```

## 🏥 Health Check Endpoints

The application includes comprehensive health check endpoints:

### **Available Endpoints**
- `GET /health` - Basic liveness check
- `GET /health/live` - Alias for liveness
- `GET /health/ready` - Readiness check with dependencies
- `GET /health/startup` - Startup check for initialization
- `GET /health/detailed` - Detailed health information

### **Integration with Kubernetes**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 5

startupProbe:
  httpGet:
    path: /health/startup
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 10
```

## 🔍 Security Validation

### **Container Security Scan**
```bash
# Scan for vulnerabilities (using Trivy)
trivy image webgoat-core:secure

# Check for misconfigurations
trivy config Dockerfile

# Runtime security check
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image webgoat-core:secure
```

### **Runtime Security Verification**
```bash
# Verify non-root execution
docker exec webgoat-core whoami
# Should return: appuser

# Check file permissions
docker exec webgoat-core ls -la /app
# Should show files owned by appuser with proper permissions

# Verify no shell access
docker exec webgoat-core /bin/sh
# Should fail or show restricted shell
```

### **Security Checklist**
- [ ] Container runs as non-root user (UID 1001)
- [ ] Read-only root filesystem implemented
- [ ] No unnecessary Linux capabilities
- [ ] Proper signal handling with dumb-init
- [ ] Health checks responding correctly
- [ ] No secrets in image layers
- [ ] Minimal attack surface
- [ ] Security updates applied
- [ ] Resource limits configured
- [ ] Network policies applied

## 🔒 Production Deployment Security

### **Environment Variables**
```bash
# Secure environment configuration
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://+:8080
ASPNETCORE_FORWARDEDHEADERS_ENABLED=true
DOTNET_EnableDiagnostics=0
COMPlus_EnableDiagnostics=0
```

### **Secrets Management**
- Use external secret management (Azure Key Vault, HashiCorp Vault)
- Mount secrets as volumes, not environment variables
- Rotate secrets regularly
- Use Docker secrets or Kubernetes secrets

### **Network Security**
- Deploy behind reverse proxy (nginx, HAProxy)
- Use TLS termination at load balancer
- Implement rate limiting
- Configure proper security headers

## 🚨 Security Considerations

### **Known Vulnerabilities Fixed**
- ✅ Updated to latest .NET 5.0.17 runtime
- ✅ All NuGet packages use specific versions
- ✅ Base OS packages updated during build
- ✅ Removed development tools from runtime image

### **Additional Security Measures**
- **Image Scanning**: Regularly scan for vulnerabilities
- **Dependency Updates**: Keep NuGet packages updated
- **Security Headers**: Implement proper HTTP security headers
- **Logging**: Configure secure, structured logging
- **Monitoring**: Implement runtime security monitoring

## 📊 Performance & Monitoring

### **Resource Requirements**
- **Memory**: 256-512 MB
- **CPU**: 0.1-0.5 cores
- **Storage**: ~100 MB image size
- **Network**: Port 8080

### **Monitoring Integration**
- Health check endpoints for load balancers
- Prometheus metrics (if configured)
- Structured logging for centralized log management
- Application Performance Monitoring (APM) ready

This Dockerfile implements industry-standard security practices and provides a production-ready, secure container for the WebGoat Core application.
