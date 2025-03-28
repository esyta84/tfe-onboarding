# Setting Up Azure Storage for Terraform State

This guide explains how to set up Azure Storage for storing Terraform state files, which is a prerequisite for the Azure DevOps pipelines in this repository.

## Overview

Terraform state files track the resources managed by Terraform. When working in a team or with automated pipelines, it's essential to store these state files in a shared, secure location. Azure Storage is an excellent option for this purpose.

## Prerequisites

- An Azure subscription
- Azure CLI installed or access to the Azure Portal
- Contributor access to the subscription

## Step 1: Create Resource Group

First, create a resource group to contain your storage resources:

```bash
# Using Azure CLI
az group create --name tfstate --location eastus
```

Or use the Azure Portal:
1. Navigate to Resource Groups
2. Click "Create"
3. Name it "tfstate"
4. Select a region (e.g., East US)
5. Click "Review + create", then "Create"

## Step 2: Create Storage Account

Create a storage account within the resource group:

```bash
# Replace <unique-storage-name> with a globally unique name
az storage account create --name <unique-storage-name> --resource-group tfstate --sku Standard_LRS --encryption-services blob
```

Or use the Azure Portal:
1. Navigate to the "tfstate" resource group
2. Click "Create" and select "Storage account"
3. Give it a unique name (e.g., "tfstate" + your organization name)
4. Select "Standard" performance and "Locally redundant storage (LRS)"
5. Complete the required fields and create the account

## Step 3: Create Blob Container

Create a container to store the Terraform state files:

```bash
# Using Azure CLI (replace <unique-storage-name> with your storage account name)
az storage container create --name terraform-state --account-name <unique-storage-name> --auth-mode login
```

Or use the Azure Portal:
1. Navigate to your storage account
2. Go to "Containers" under "Data storage"
3. Click "+ Container"
4. Name it "terraform-state"
5. Set the public access level to "Private"
6. Click "Create"

## Step 4: Configure Azure DevOps Service Connection

1. In Azure DevOps, go to **Project Settings** > **Service connections**
2. Click **New service connection** > **Azure Resource Manager**
3. Select **Service principal (automatic)** for authentication
4. Choose **Subscription** for scope level
5. Select your Azure subscription
6. Name the service connection "TFEServiceConnection"
7. Optionally, add a description
8. Check "Grant access permission to all pipelines"
9. Click "Save"

## Step 5: Update Pipeline YAML Files (If Needed)

If you're using a different storage account name or resource group, update the following in all pipeline YAML files:

```yaml
backendAzureRmResourceGroupName: 'tfstate'  # Replace with your resource group name
backendAzureRmStorageAccountName: 'tfstate$(Build.DefinitionName)'  # Replace with your storage account name
backendAzureRmContainerName: 'terraform-state'  # Replace with your container name
```

## Security Best Practices

1. **Access Controls**: Limit who can access the storage account.
2. **Encryption**: Ensure encryption is enabled for the storage account.
3. **Network Rules**: Consider implementing network rules to restrict access to specific networks.
4. **State Locking**: The Azure backend supports state locking to prevent concurrent operations.
5. **Versioning**: Enable soft delete or versioning to protect against accidental deletion.

## Troubleshooting

- **Access Denied**: Ensure the service principal has Contributor access to the resource group.
- **State File Conflicts**: If you see errors about state file conflicts, someone else may be running Terraform. Resolve the lock and try again.
- **Storage Account Not Found**: Verify the storage account name and resource group are correct in your pipeline configuration.

## Next Steps

Once your Azure Storage is set up, you can proceed with configuring the Azure DevOps pipelines as described in the [Azure DevOps Pipeline README](README.md). 