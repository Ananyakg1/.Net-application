# Kubernetes Deployment Guide for .NET Application

This directory contains comprehensive Kubernetes manifests with security best practices for deploying the WebGoat Core .NET application.

## Files Overview

| File | Description |
|------|-------------|
| `namespace.yaml` | Creates the `dotnet-namespace` with proper labeling |
| `configmap.yaml` | Application configuration and environment variables |
| `secrets.yaml` | Sensitive configuration data (passwords, API keys) |
| `rbac.yaml` | Service account, roles, and role bindings |
| `deployment.yaml` | Main application deployment with security contexts |
| `service.yaml` | ClusterIP services (regular and headless) |
| `network-policy.yaml` | Network policies for traffic control |
| `scaling.yaml` | HPA and PodDisruptionBudget for high availability |

## Security Features Implemented

### 🔒 Pod Security
- **Security Contexts**: Run as non-root user (UID 1001)
- **Read-only Root Filesystem**: Prevents runtime modifications
- **Dropped Capabilities**: Removes all Linux capabilities except NET_BIND_SERVICE
- **SecComp Profile**: Uses runtime/default profile
- **AppArmor**: Runtime protection (where supported)

### 🛡️ Container Security
- **Resource Limits**: Prevents resource exhaustion
- **Image Pull Policy**: Always pull latest for security updates
- **No Privilege Escalation**: Prevents container breakout
- **Temporary Filesystems**: Writable directories mounted as emptyDir

### 🌐 Network Security
- **Network Policies**: Restrict ingress/egress traffic
- **Default Deny**: All traffic denied by default
- **Selective Allow**: Only necessary communication permitted
- **DNS Resolution**: Limited to required ports

### 🔑 Access Control
- **RBAC**: Minimal required permissions
- **Service Account**: Dedicated SA with no token mounting
- **Role-based Access**: Limited to necessary resources

### 📊 Observability & Health
- **Health Checks**: Liveness, readiness, and startup probes
- **Monitoring**: Prometheus annotations
- **Logging**: Structured logging configuration

## Deployment Instructions

### 1. Prerequisites
```bash
# Ensure you have a Kubernetes cluster and kubectl configured
kubectl cluster-info

# Install metrics server for HPA (if not already installed)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 2. Deploy in Order
```bash
# 1. Create namespace
kubectl apply -f namespace.yaml

# 2. Create RBAC resources
kubectl apply -f rbac.yaml

# 3. Create configuration
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml

# 4. Deploy network policies
kubectl apply -f network-policy.yaml

# 5. Deploy application
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 6. Configure scaling
kubectl apply -f scaling.yaml
```

### 3. Verify Deployment
```bash
# Check all resources
kubectl get all -n dotnet-namespace

# Verify pods are running
kubectl get pods -n dotnet-namespace

# Check security contexts
kubectl describe pod -n dotnet-namespace -l app=dotnet-app

# Test network policies
kubectl exec -n dotnet-namespace -it deployment/dotnet-app -- /bin/sh
```

## Configuration Customization

### Environment Variables (configmap.yaml)
Update the ConfigMap with your specific environment variables:
- Database connection strings
- API endpoints
- Feature flags
- Logging levels

### Secrets (secrets.yaml)
**⚠️ IMPORTANT**: Replace the base64 encoded values with your actual secrets:
```bash
# Encode your secrets
echo -n "your-actual-password" | base64
```

### Resource Limits (deployment.yaml)
Adjust based on your application requirements:
- **Memory**: Currently set to 256Mi request, 512Mi limit
- **CPU**: Currently set to 100m request, 500m limit
- **Storage**: Ephemeral storage limits included

### Health Check Endpoints
Ensure your .NET application exposes these endpoints:
- `/health` - Liveness probe
- `/health/ready` - Readiness probe  
- `/health/startup` - Startup probe

## Security Considerations

### 🚨 Before Production
1. **Update Secrets**: Replace all placeholder secrets with real values
2. **Review Network Policies**: Adjust based on your network architecture
3. **Validate Resource Limits**: Test under load
4. **Security Scanning**: Scan container images for vulnerabilities
5. **Certificate Management**: Implement proper TLS certificates

### 🔍 Security Validation
```bash
# Check security contexts
kubectl get pods -n dotnet-namespace -o jsonpath='{.items[*].spec.securityContext}'

# Verify network policies
kubectl get networkpolicies -n dotnet-namespace

# Check RBAC permissions
kubectl auth can-i --list --as=system:serviceaccount:dotnet-namespace:dotnet-service-account
```

## Monitoring & Troubleshooting

### View Logs
```bash
# Application logs
kubectl logs -n dotnet-namespace -l app=dotnet-app

# Follow logs from all replicas
kubectl logs -n dotnet-namespace -l app=dotnet-app -f
```

### Debug Network Issues
```bash
# Test internal connectivity
kubectl exec -n dotnet-namespace -it deployment/dotnet-app -- curl http://dotnet-service

# Check network policies
kubectl describe networkpolicy -n dotnet-namespace
```

### Scale Application
```bash
# Manual scaling
kubectl scale deployment dotnet-app -n dotnet-namespace --replicas=5

# Check HPA status
kubectl get hpa -n dotnet-namespace
```

## Additional Security Enhancements

For enhanced security, consider implementing:
- **Pod Security Standards** (PSS) or **Pod Security Policies** (deprecated)
- **OPA Gatekeeper** policies
- **Falco** for runtime security monitoring  
- **Network segmentation** with service mesh (Istio/Linkerd)
- **Image scanning** in CI/CD pipeline
- **Secrets management** with external systems (HashiCorp Vault, Azure Key Vault)

## Support

For issues or questions:
1. Check pod status and logs
2. Verify network connectivity
3. Review security contexts and policies
4. Ensure all dependencies are properly deployed
