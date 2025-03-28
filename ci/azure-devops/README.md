# Azure DevOps CI/CD Pipeline for Terraform Enterprise Onboarding

This directory contains the Azure DevOps pipeline configurations for automating the deployment of Terraform Enterprise (TFE) team onboarding infrastructure. These pipelines help ensure consistent, repeatable deployments across environments.

## Pipeline Overview

The following pipelines are available:

1. **azure-pipelines-ci.yml** - Continuous integration pipeline for validating and planning Terraform changes.
2. **azure-pipelines-cd.yml** - Continuous deployment pipeline for applying Terraform changes to different environments (dev, preprod, prod).
3. **azure-pipelines-team-onboarding.yml** - Specialized pipeline for onboarding new teams with parameterized inputs.

## Prerequisites

Before using these pipelines, ensure you have:

1. An Azure DevOps account and project set up.
2. Terraform installed on your build agents or use Microsoft-hosted agents.
3. A Service Connection to Azure for storing state files (see [state-storage-setup.md](state-storage-setup.md) for detailed setup instructions).
4. Variable groups set up for sensitive information (see below).
5. Appropriate permissions to create and run pipelines.

## Setting Up Service Connections

### Azure Service Connection

Create an Azure Service Connection in Azure DevOps:

1. Go to **Project Settings** > **Service connections** > **New service connection** > **Azure Resource Manager**.
2. Name it `TFEServiceConnection`.
3. Ensure it has contributor access to the subscription or resource group where you'll store Terraform state.

For a detailed guide on setting up the Azure Storage for Terraform state and creating the necessary service connection, see [state-storage-setup.md](state-storage-setup.md).

## Variable Groups

Create a variable group named `tfe-variables` with the following variables:

- `tfe_token`: The API token for Terraform Enterprise (mark as secret)
- `tfe_organization`: Your Terraform Enterprise organization name

## Setting Up Pipelines

### Continuous Integration (CI) Pipeline

1. In Azure DevOps, go to **Pipelines** > **New Pipeline**.
2. Select **Azure Repos Git** (or your code source).
3. Select your repository.
4. Select **Existing Azure Pipelines YAML file**.
5. Select `/ci/azure-devops/azure-pipelines-ci.yml`.
6. Review and create the pipeline.

### Continuous Deployment (CD) Pipeline

1. In Azure DevOps, go to **Pipelines** > **New Pipeline**.
2. Select **Azure Repos Git** (or your code source).
3. Select your repository.
4. Select **Existing Azure Pipelines YAML file**.
5. Select `/ci/azure-devops/azure-pipelines-cd.yml`.
6. Review and create the pipeline.

### Team Onboarding Pipeline

1. In Azure DevOps, go to **Pipelines** > **New Pipeline**.
2. Select **Azure Repos Git** (or your code source).
3. Select your repository.
4. Select **Existing Azure Pipelines YAML file**.
5. Select `/ci/azure-devops/azure-pipelines-team-onboarding.yml`.
6. Review and create the pipeline.

## Environment Setup

For the CD and Team Onboarding pipelines, you need to set up environments in Azure DevOps:

1. Go to **Pipelines** > **Environments**.
2. Create environments called `dev`, `preprod`, and `prod`.
3. Configure approval checks for each environment as needed.

## Using the Team Onboarding Pipeline

The team onboarding pipeline is parameterized and can be triggered with different parameters:

1. Go to **Pipelines** and select the team onboarding pipeline.
2. Click **Run pipeline**.
3. Fill in the parameters:
   - **Team Name**: The name of the team to onboard
   - **Team Description**: A description of the team
   - **Team Email**: Contact email for the team
   - **Cost Code**: Team cost code for billing
   - **Platforms**: Comma-separated list of platforms the team needs (vsphere,aws,azure)
   - **Environments**: Comma-separated list of environments the team needs (dev,preprod,prod)
   - **Team Admins**: Comma-separated list of admin email addresses
   - **Team Members**: Comma-separated list of member email addresses
   - **Target Environment**: The environment to deploy to (dev, preprod, or prod)
4. Click **Run** to start the pipeline.

## Best Practices

1. **Review Generated Plans**: Always review the Terraform plan before applying changes.
2. **Progressive Deployments**: Deploy to dev, then preprod, and finally to prod, confirming at each step.
3. **Module Versioning**: Use specific versions of modules to ensure consistency.
4. **Environment Isolation**: Keep the state files separate for each environment.
5. **Parameterized Pipelines**: Use parameters to make pipelines reusable and reduce duplication.

## Troubleshooting

- **State Lock Issues**: If a pipeline fails, there may be a state lock. Verify in Azure Storage.
- **Permission Errors**: Ensure the service connection has proper permissions on Azure resources.
- **Variable Errors**: Check that all required variables are present in the variable groups.
- **Pipeline Agent Errors**: Verify the pipeline agent has the right extensions installed for Terraform.

## Related Documentation

- [Setting Up Azure Storage for Terraform State](state-storage-setup.md)
- [Terraform Enterprise Documentation](https://developer.hashicorp.com/terraform/enterprise)
- [Azure DevOps Pipeline Documentation](https://docs.microsoft.com/en-us/azure/devops/pipelines/?view=azure-devops) 