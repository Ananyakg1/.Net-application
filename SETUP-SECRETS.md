# GitHub Secrets Setup Guide

This document provides step-by-step instructions to set up the required GitHub secrets for the CI/CD pipeline.

## 🔐 Required GitHub Secrets

Navigate to your repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

### **1. Azure Service Principal Credentials**

#### **Option A: Individual Secrets (Recommended)**
Create these individual secrets:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `AZURE_CLIENT_ID` | Service Principal Application ID | Azure Portal → App Registrations → Your App → Application ID |
| `AZURE_CLIENT_SECRET` | Service Principal Secret | Azure Portal → App Registrations → Your App → Certificates & secrets |
| `AZURE_TENANT_ID` | Azure Tenant ID | Azure Portal → Azure Active Directory → Properties → Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | Azure Portal → Subscriptions → Your Subscription → Subscription ID |

#### **Option B: Combined Credentials (Alternative)**
Create one secret named `AZURE_CREDENTIALS` with this JSON format:
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}
```

### **2. Azure Container Registry (ACR) Secrets**

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `REGISTRY_LOGIN_SERVER` | ACR Login Server | `myregistry.azurecr.io` |
| `REGISTRY_USERNAME` | ACR Admin Username | `myregistry` |
| `REGISTRY_PASSWORD` | ACR Admin Password | `acr-admin-password` |

#### **How to Get ACR Credentials:**
```bash
# Get ACR login server
az acr show --name <registry-name> --query loginServer --output tsv

# Enable admin user and get credentials
az acr update -n <registry-name> --admin-enabled true
az acr credential show --name <registry-name>
```

### **3. Azure Kubernetes Service (AKS) Secrets**

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AKS_CLUSTER_NAME` | AKS Cluster Name | `my-aks-cluster` |
| `AKS_RESOURCE_GROUP` | Azure Resource Group | `my-resource-group` |

## 🚀 Creating Azure Service Principal

If you don't have a service principal, create one:

### **Method 1: Using Azure CLI**
```bash
# Create service principal
az ad sp create-for-rbac --name "github-actions-sp" --role contributor \
  --scopes /subscriptions/{subscription-id} --sdk-auth

# Output will be JSON - use this for AZURE_CREDENTIALS secret
```

### **Method 2: Using Azure Portal**
1. Go to **Azure Active Directory** → **App registrations** → **New registration**
2. Name: `github-actions-sp`
3. After creation, note the **Application (client) ID** and **Directory (tenant) ID**
4. Go to **Certificates & secrets** → **New client secret**
5. Note the **Secret value** (not the ID)
6. Go to your **Subscription** → **Access control (IAM)** → **Add role assignment**
7. Role: **Contributor**, Assign access to: **Service principal**, Select: your created app

## 🔧 Permissions Required

Your service principal needs these permissions:

### **Azure Subscription Level:**
- **Contributor** role on the subscription or resource group
- **AcrPush** role on the Azure Container Registry
- **Azure Kubernetes Service Cluster User Role** on the AKS cluster

### **PowerShell Commands to Assign Roles:**
```powershell
# Assign Contributor role
az role assignment create --assignee <client-id> \
  --role "Contributor" \
  --scope /subscriptions/<subscription-id>

# Assign AcrPush role
az role assignment create --assignee <client-id> \
  --role "AcrPush" \
  --scope /subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.ContainerRegistry/registries/<acr-name>

# Assign AKS Cluster User role
az role assignment create --assignee <client-id> \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope /subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.ContainerService/managedClusters/<aks-name>
```

## ✅ Verification

### **Test Azure CLI Authentication:**
```bash
az login --service-principal \
  --username <client-id> \
  --password <client-secret> \
  --tenant <tenant-id>

# Test ACR access
az acr login --name <registry-name>

# Test AKS access
az aks get-credentials --resource-group <rg-name> --name <aks-name>
kubectl get nodes
```

### **Test Complete Setup:**
After adding all secrets, push a commit to trigger the workflow and verify:
1. ✅ Azure authentication succeeds
2. ✅ ACR login succeeds
3. ✅ Docker build and push succeed
4. ✅ AKS deployment succeeds

## 🔒 Security Best Practices

### **Secret Management:**
- ✅ Use individual secrets instead of combined JSON when possible
- ✅ Regularly rotate service principal secrets
- ✅ Use minimum required permissions (principle of least privilege)
- ✅ Monitor service principal usage in Azure AD audit logs

### **Service Principal Security:**
- ✅ Set expiration dates on client secrets
- ✅ Use certificate-based authentication when possible
- ✅ Regularly review and audit permissions
- ✅ Delete unused service principals

## 🛠️ Troubleshooting

### **Common Issues:**

#### **Authentication Errors:**
- Verify service principal has correct permissions
- Check if client secret has expired
- Ensure tenant ID and subscription ID are correct

#### **ACR Access Issues:**
- Verify ACR admin user is enabled
- Check if service principal has AcrPush role
- Confirm registry login server URL format

#### **AKS Access Issues:**
- Ensure service principal has AKS cluster user role
- Verify cluster name and resource group
- Check if cluster is running and accessible

### **Debug Commands:**
```bash
# Check service principal details
az ad sp show --id <client-id>

# List role assignments
az role assignment list --assignee <client-id>

# Test ACR connectivity
az acr check-health --name <registry-name>

# Test AKS connectivity
az aks show --resource-group <rg-name> --name <aks-name>
```

## 📞 Support

If you encounter issues:

1. **Check GitHub Actions logs** for specific error messages
2. **Verify all secrets are correctly named and formatted**
3. **Test Azure CLI commands manually** with the same credentials
4. **Review Azure AD audit logs** for authentication failures
5. **Check Azure resource permissions** and access policies

---

**Note:** Keep your secrets secure and never commit them to your repository. Always use GitHub's encrypted secrets feature for sensitive information.
