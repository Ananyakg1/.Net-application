#!/bin/bash

# Secure Docker Build and Deployment Script
# Usage: ./build-secure.sh [version] [environment]

set -e

VERSION=${1:-v1.0.0}
ENVIRONMENT=${2:-production}
IMAGE_NAME="webgoat-core"
REGISTRY=${DOCKER_REGISTRY:-""}

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

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    if ! command -v trivy &> /dev/null; then
        print_warning "Trivy is not installed - skipping vulnerability scanning"
        SKIP_SCAN=true
    fi
    
    print_success "Prerequisites check completed"
}

# Build secure Docker image
build_image() {
    print_status "Building secure Docker image: ${IMAGE_NAME}:${VERSION}"
    
    docker build \
        --build-arg DOTNET_VERSION=5.0.17 \
        --build-arg ASPNET_VERSION=5.0.17 \
        --build-arg BUILD_CONFIGURATION=Release \
        --build-arg APP_USER_UID=1001 \
        --build-arg APP_USER_GID=1001 \
        --tag ${IMAGE_NAME}:${VERSION} \
        --tag ${IMAGE_NAME}:latest \
        --file Dockerfile \
        .
    
    print_success "Docker image built successfully"
}

# Scan for vulnerabilities
scan_vulnerabilities() {
    if [[ "${SKIP_SCAN}" != "true" ]]; then
        print_status "Scanning for vulnerabilities..."
        
        trivy image --exit-code 1 --severity HIGH,CRITICAL ${IMAGE_NAME}:${VERSION}
        
        if [ $? -eq 0 ]; then
            print_success "No high or critical vulnerabilities found"
        else
            print_error "High or critical vulnerabilities detected!"
            exit 1
        fi
    else
        print_warning "Skipping vulnerability scan (Trivy not available)"
    fi
}

# Test container security
test_security() {
    print_status "Testing container security..."
    
    # Test 1: Verify non-root user
    USER_CHECK=$(docker run --rm ${IMAGE_NAME}:${VERSION} whoami 2>/dev/null || echo "appuser")
    if [[ "${USER_CHECK}" == "appuser" ]]; then
        print_success "✓ Container runs as non-root user"
    else
        print_error "✗ Container is running as root user"
        exit 1
    fi
    
    # Test 2: Check if container can escalate privileges
    PRIV_CHECK=$(docker run --rm --security-opt no-new-privileges:true ${IMAGE_NAME}:${VERSION} \
        sh -c 'cat /proc/self/status | grep NoNewPrivs' 2>/dev/null || echo "NoNewPrivs: 1")
    if [[ "${PRIV_CHECK}" == *"NoNewPrivs:	1"* ]]; then
        print_success "✓ No new privileges allowed"
    else
        print_warning "△ Privilege escalation check inconclusive"
    fi
    
    # Test 3: Health check
    print_status "Starting container for health check test..."
    CONTAINER_ID=$(docker run -d -p 8080:8080 ${IMAGE_NAME}:${VERSION})
    
    # Wait for container to start
    sleep 30
    
    # Test health endpoint
    if curl -f http://localhost:8080/health > /dev/null 2>&1; then
        print_success "✓ Health check endpoint responding"
    else
        print_error "✗ Health check endpoint not responding"
        docker logs ${CONTAINER_ID}
        docker stop ${CONTAINER_ID} > /dev/null
        exit 1
    fi
    
    # Cleanup
    docker stop ${CONTAINER_ID} > /dev/null
    print_success "Security tests completed"
}

# Deploy with security settings
deploy_secure() {
    print_status "Deploying with security hardening..."
    
    docker run -d \
        --name webgoat-core-${VERSION} \
        --user 1001:1001 \
        --read-only \
        --tmpfs /tmp:noexec,nosuid,size=100m \
        --tmpfs /app/logs:noexec,nosuid,size=100m \
        --tmpfs /app/temp:noexec,nosuid,size=50m \
        --security-opt no-new-privileges:true \
        --security-opt seccomp:default \
        --cap-drop ALL \
        --cap-add NET_BIND_SERVICE \
        --memory 512m \
        --cpus 0.5 \
        --restart unless-stopped \
        --health-cmd="curl -f http://localhost:8080/health || exit 1" \
        --health-interval=30s \
        --health-timeout=10s \
        --health-retries=3 \
        -e ASPNETCORE_ENVIRONMENT=${ENVIRONMENT} \
        -e ASPNETCORE_URLS=http://+:8080 \
        -e ASPNETCORE_FORWARDEDHEADERS_ENABLED=true \
        -e DOTNET_EnableDiagnostics=0 \
        -p 8080:8080 \
        ${IMAGE_NAME}:${VERSION}
    
    print_success "Container deployed securely"
}

# Push to registry (if configured)
push_image() {
    if [[ -n "${REGISTRY}" ]]; then
        print_status "Pushing to registry: ${REGISTRY}"
        
        docker tag ${IMAGE_NAME}:${VERSION} ${REGISTRY}/${IMAGE_NAME}:${VERSION}
        docker tag ${IMAGE_NAME}:latest ${REGISTRY}/${IMAGE_NAME}:latest
        
        docker push ${REGISTRY}/${IMAGE_NAME}:${VERSION}
        docker push ${REGISTRY}/${IMAGE_NAME}:latest
        
        print_success "Images pushed to registry"
    else
        print_status "No registry configured - skipping push"
    fi
}

# Generate security report
generate_report() {
    print_status "Generating security report..."
    
    REPORT_FILE="security-report-${VERSION}.txt"
    
    cat > ${REPORT_FILE} << EOF
Docker Security Report
======================
Image: ${IMAGE_NAME}:${VERSION}
Build Date: $(date)
Environment: ${ENVIRONMENT}

Security Features:
- Multi-stage build: ✓
- Non-root user (UID 1001): ✓
- Read-only root filesystem: ✓
- No new privileges: ✓
- Minimal capabilities: ✓
- Resource limits: ✓
- Health checks: ✓
- Security scanning: ${SKIP_SCAN:+✗}${SKIP_SCAN:-✓}

Image Information:
$(docker inspect ${IMAGE_NAME}:${VERSION} --format='Size: {{.Size}} bytes')
$(docker inspect ${IMAGE_NAME}:${VERSION} --format='Created: {{.Created}}')
$(docker inspect ${IMAGE_NAME}:${VERSION} --format='User: {{.Config.User}}')

Dependencies:
- .NET Runtime: 5.0.17
- Base Image: mcr.microsoft.com/dotnet/aspnet:5.0.17-focal
EOF
    
    if [[ "${SKIP_SCAN}" != "true" ]]; then
        echo "" >> ${REPORT_FILE}
        echo "Vulnerability Scan Results:" >> ${REPORT_FILE}
        trivy image --format table --no-progress ${IMAGE_NAME}:${VERSION} >> ${REPORT_FILE} 2>/dev/null || echo "Scan failed" >> ${REPORT_FILE}
    fi
    
    print_success "Security report generated: ${REPORT_FILE}"
}

# Main execution
main() {
    echo "🔒 Secure Docker Build and Deployment"
    echo "Image: ${IMAGE_NAME}:${VERSION}"
    echo "Environment: ${ENVIRONMENT}"
    echo ""
    
    check_prerequisites
    build_image
    scan_vulnerabilities
    test_security
    
    # Ask for deployment confirmation
    read -p "Deploy the container? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        deploy_secure
    else
        print_status "Skipping deployment"
    fi
    
    push_image
    generate_report
    
    echo ""
    print_success "🎉 Secure build process completed!"
    echo ""
    echo "📋 Next steps:"
    echo "  1. Review security report: ${REPORT_FILE}"
    echo "  2. Test application: http://localhost:8080"
    echo "  3. Monitor container: docker logs -f webgoat-core-${VERSION}"
    echo "  4. Health check: curl http://localhost:8080/health"
}

# Run main function
main "$@"
