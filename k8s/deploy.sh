#!/bin/bash

# Deploy .NET Application to Kubernetes with Security Best Practices
# Usage: ./deploy.sh [environment]

set -e

ENVIRONMENT=${1:-production}
NAMESPACE="dotnet-namespace"

echo "🚀 Deploying .NET application to Kubernetes..."
echo "Environment: $ENVIRONMENT"
echo "Namespace: $NAMESPACE"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster"
    exit 1
fi

print_status "Connected to cluster: $(kubectl config current-context)"

# Validate secrets before deployment
print_warning "⚠️  SECURITY REMINDER: Ensure you have updated the secrets in secrets.yaml with real values!"
read -p "Have you updated the secrets with real values? (y/N): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Please update secrets.yaml with real values before deploying to production"
    exit 1
fi

# Deploy resources in order
print_status "1. Creating namespace..."
kubectl apply -f namespace.yaml
print_success "Namespace created"

print_status "2. Setting up RBAC..."
kubectl apply -f rbac.yaml
print_success "RBAC configured"

print_status "3. Creating configuration..."
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml
print_success "Configuration applied"

print_status "4. Applying network policies..."
kubectl apply -f network-policy.yaml
print_success "Network policies applied"

print_status "5. Deploying application..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
print_success "Application deployed"

print_status "6. Configuring scaling..."
kubectl apply -f scaling.yaml
print_success "Scaling configured"

# Wait for deployment to be ready
print_status "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/dotnet-app -n $NAMESPACE

# Verify deployment
print_status "Verifying deployment..."
READY_REPLICAS=$(kubectl get deployment dotnet-app -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
DESIRED_REPLICAS=$(kubectl get deployment dotnet-app -n $NAMESPACE -o jsonpath='{.spec.replicas}')

if [ "$READY_REPLICAS" -eq "$DESIRED_REPLICAS" ]; then
    print_success "Deployment successful! $READY_REPLICAS/$DESIRED_REPLICAS replicas ready"
else
    print_error "Deployment may have issues. Ready: $READY_REPLICAS, Desired: $DESIRED_REPLICAS"
fi

# Show deployment status
echo ""
print_status "Deployment Status:"
kubectl get all -n $NAMESPACE

echo ""
print_status "Security Verification:"
echo "📋 Checking security contexts..."
kubectl get pods -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name}: RunAsUser={.spec.securityContext.runAsUser}, ReadOnlyRootFilesystem={.spec.containers[0].securityContext.readOnlyRootFilesystem}{"\n"}{end}'

echo ""
echo "🔒 Network Policies:"
kubectl get networkpolicies -n $NAMESPACE

echo ""
echo "🎯 Services:"
kubectl get services -n $NAMESPACE

echo ""
echo "📊 HPA Status:"
kubectl get hpa -n $NAMESPACE

echo ""
print_success "🎉 Deployment completed successfully!"
echo ""
echo "📝 Next steps:"
echo "  1. Test application connectivity:"
echo "     kubectl port-forward -n $NAMESPACE svc/dotnet-service 8080:80"
echo "  2. Check application logs:"
echo "     kubectl logs -n $NAMESPACE -l app=dotnet-app -f"
echo "  3. Monitor HPA scaling:"
echo "     kubectl get hpa -n $NAMESPACE -w"
echo "  4. Verify security policies:"
echo "     kubectl auth can-i --list --as=system:serviceaccount:$NAMESPACE:dotnet-service-account"
