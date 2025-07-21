@echo off
REM Deploy .NET Application to Kubernetes with Security Best Practices
REM Usage: deploy.bat [environment]

setlocal enabledelayedexpansion

set "ENVIRONMENT=%~1"
if "%ENVIRONMENT%"=="" set "ENVIRONMENT=production"
set "NAMESPACE=dotnet-namespace"

echo 🚀 Deploying .NET application to Kubernetes...
echo Environment: %ENVIRONMENT%
echo Namespace: %NAMESPACE%

REM Check if kubectl is available
kubectl version --client >nul 2>&1
if errorlevel 1 (
    echo [ERROR] kubectl is not installed or not in PATH
    exit /b 1
)

REM Check if cluster is accessible
kubectl cluster-info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Cannot connect to Kubernetes cluster
    exit /b 1
)

echo [INFO] Connected to cluster
for /f "tokens=*" %%i in ('kubectl config current-context') do echo Context: %%i

REM Security reminder
echo.
echo ⚠️  SECURITY REMINDER: Ensure you have updated the secrets in secrets.yaml with real values!
set /p "answer=Have you updated the secrets with real values? (y/N): "
if /i not "%answer%"=="y" (
    echo [ERROR] Please update secrets.yaml with real values before deploying to production
    exit /b 1
)

REM Deploy resources in order
echo [INFO] 1. Creating namespace...
kubectl apply -f namespace.yaml
if errorlevel 1 (
    echo [ERROR] Failed to create namespace
    exit /b 1
)
echo [SUCCESS] Namespace created

echo [INFO] 2. Setting up RBAC...
kubectl apply -f rbac.yaml
if errorlevel 1 (
    echo [ERROR] Failed to setup RBAC
    exit /b 1
)
echo [SUCCESS] RBAC configured

echo [INFO] 3. Creating configuration...
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml
if errorlevel 1 (
    echo [ERROR] Failed to apply configuration
    exit /b 1
)
echo [SUCCESS] Configuration applied

echo [INFO] 4. Applying network policies...
kubectl apply -f network-policy.yaml
if errorlevel 1 (
    echo [ERROR] Failed to apply network policies
    exit /b 1
)
echo [SUCCESS] Network policies applied

echo [INFO] 5. Deploying application...
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
if errorlevel 1 (
    echo [ERROR] Failed to deploy application
    exit /b 1
)
echo [SUCCESS] Application deployed

echo [INFO] 6. Configuring scaling...
kubectl apply -f scaling.yaml
if errorlevel 1 (
    echo [ERROR] Failed to configure scaling
    exit /b 1
)
echo [SUCCESS] Scaling configured

REM Wait for deployment to be ready
echo [INFO] Waiting for deployment to be ready...
kubectl wait --for=condition=available --timeout=300s deployment/dotnet-app -n %NAMESPACE%
if errorlevel 1 (
    echo [WARNING] Deployment may not be fully ready yet
)

REM Show deployment status
echo.
echo [INFO] Deployment Status:
kubectl get all -n %NAMESPACE%

echo.
echo [INFO] Security Verification:
echo 📋 Checking security contexts...
kubectl get pods -n %NAMESPACE% -o jsonpath="{range .items[*]}{.metadata.name}: RunAsUser={.spec.securityContext.runAsUser}, ReadOnlyRootFilesystem={.spec.containers[0].securityContext.readOnlyRootFilesystem}{'\n'}{end}"

echo.
echo 🔒 Network Policies:
kubectl get networkpolicies -n %NAMESPACE%

echo.
echo 🎯 Services:
kubectl get services -n %NAMESPACE%

echo.
echo 📊 HPA Status:
kubectl get hpa -n %NAMESPACE%

echo.
echo [SUCCESS] 🎉 Deployment completed successfully!
echo.
echo 📝 Next steps:
echo   1. Test application connectivity:
echo      kubectl port-forward -n %NAMESPACE% svc/dotnet-service 8080:80
echo   2. Check application logs:
echo      kubectl logs -n %NAMESPACE% -l app=dotnet-app -f
echo   3. Monitor HPA scaling:
echo      kubectl get hpa -n %NAMESPACE% -w
echo   4. Verify security policies:
echo      kubectl auth can-i --list --as=system:serviceaccount:%NAMESPACE%:dotnet-service-account

endlocal
