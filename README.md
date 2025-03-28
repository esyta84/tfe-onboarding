# Terraform Enterprise Onboarding Automation

This repository contains Terraform code for automating team onboarding to our Terraform Enterprise platform. It provides a scalable, modular approach to managing hundreds of workspaces across different teams and environments.

## Overview

This codebase enables the automated creation and management of:

- Team organizations in Terraform Enterprise
- Projects for different environments (dev, preprod, prod)
- Workspaces for different platforms (vSphere, AWS, Azure)
- Variable sets for platform-specific configurations
- Team-specific variables
- Administrative workflows for platform management

## Repository Structure

```
.
├── README.md                       # This file
├── main.tf                         # Root module entry point
├── variables.tf                    # Global variables definition
├── outputs.tf                      # Global outputs
├── providers.tf                    # Provider configurations
├── terraform.tfvars.example        # Example variable values
├── environments/                   # Environment-specific variable files
│   ├── dev.tfvars                  # Development environment variables
│   ├── preprod.tfvars              # Pre-production environment variables
│   └── prod.tfvars                 # Production environment variables
├── modules/                        # Reusable modules
│   ├── team-foundation/            # Creates team projects and base structure
│   ├── workspace-factory/          # Creates and configures workspaces
│   ├── variable-sets/              # Manages variable sets
│   └── rbac/                       # Manages team permissions
├── teams/                          # Team-specific configurations
│   └── example-team/               # Example team configuration
├── variable-sets/                  # Predefined variable sets for platforms
│   ├── vsphere/                    # vSphere-specific variables
│   ├── aws/                        # AWS-specific variables
│   └── azure/                      # Azure-specific variables
├── admin/                          # Admin-specific workspaces and projects
│   ├── workspace-management/       # For managing workspace creation
│   └── platform-provisioning/      # For platform provisioning
└── ci/                             # CI/CD pipeline configurations
    ├── azure-devops/               # Azure DevOps pipelines
    │   ├── azure-pipelines-ci.yml  # CI pipeline for validation
    │   ├── azure-pipelines-cd.yml  # CD pipeline for deployment
    │   ├── azure-pipelines-team-onboarding.yml # Team onboarding pipeline
    │   └── README.md               # Documentation for pipeline setup
    └── gitlab-ci/                  # GitLab CI/CD pipelines
```

## Usage

### Prerequisites

- Terraform >= 1.0.0
- Terraform Enterprise account with admin privileges
- API tokens with appropriate permissions

### Getting Started

1. Clone this repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and update with your specific values
3. Initialize Terraform: `terraform init`
4. Plan the changes: `terraform plan -var-file="terraform.tfvars"`
5. Apply the changes: `terraform apply -var-file="terraform.tfvars"`

### Adding a New Team

There are two ways to onboard a new team:

#### Manual Method
1. Create a new directory under `teams/` with the team name
2. Create the necessary configuration files (see example in `teams/example-team/`)
3. Run Terraform to apply the changes

#### Automated Method Using Azure DevOps Pipeline
1. Use the Azure DevOps team onboarding pipeline (`ci/azure-devops/azure-pipelines-team-onboarding.yml`)
2. Provide the required team parameters through the Azure DevOps pipeline interface
3. The pipeline will automatically generate and apply the configuration

## State Management

This project uses a hierarchical state management approach:

- Root state manages global resources
- Each team has its own state file
- Administrative operations have separate state files

## Permissions Model

The codebase supports three permission levels:

- **Read-only users**: Can view but not modify resources
- **Approvers**: Can approve but not directly apply changes
- **Administrators**: Full control over resources

## CI/CD Integration

### Azure DevOps Pipelines

This repository includes Azure DevOps pipeline configurations for automated testing, validation, and deployment of the infrastructure code. The pipelines are located in the `ci/azure-devops/` directory:

- **CI Pipeline**: Validates and plans changes to the Terraform code
- **CD Pipeline**: Deploys changes to dev, preprod, and prod environments
- **Team Onboarding Pipeline**: Specialized pipeline for team onboarding with parameters

For detailed information on setting up and using these pipelines, see the [Azure DevOps Pipeline README](ci/azure-devops/README.md).

## SSO Integration for Team Membership

This project supports automatic team membership assignment based on identity provider groups and SAML assertions. The SSO integration module enables:

- Configuring SSO for your Terraform Enterprise organization
- Automatic team membership management via SAML assertions
- Mapping identity provider groups/roles to Terraform Enterprise teams using SSO Team IDs

### How It Works

1. When a user logs in via SSO, their SAML assertions include group/role memberships
2. Terraform Enterprise automatically assigns the user to teams based on the mapping between:
   - Identity provider group/role IDs (in the SAML attribute)
   - TFE Team SSO IDs (configured in this module)

### Supported Identity Providers

- Azure Active Directory
- Okta
- Keycloak (standard)
- Red Hat build of Keycloak
- Generic SAML providers

### Configuration

Configure SSO integration in your `terraform.tfvars` file:

```hcl
# Enable team management via SAML assertions
enable_sso_team_management = true

# SSO Provider Configuration - Azure AD Example
sso_configuration = {
  provider_type = "azure_ad"
  azure_ad_metadata_url = "https://login.microsoftonline.com/tenant-id/federationmetadata/2007-06/federationmetadata.xml"
}

# SSO Provider Configuration - Keycloak Example
# sso_configuration = {
#   provider_type = "keycloak"
#   keycloak_metadata_url = "https://keycloak.example.com/auth/realms/master/protocol/saml/descriptor"
#   keycloak_client_id = "terraform-enterprise"
#   keycloak_realm = "master"
# }

# Map identity provider groups/roles to TFE teams
sso_team_mappings = {
  admins = {
    name = "Administrators"
    sso_team_id = "<IDP-GROUP-ROLE-ID-FOR-ADMINS>"
  },
  developers = {
    name = "Developers"
    sso_team_id = "<IDP-GROUP-ROLE-ID-FOR-DEVELOPERS>"
  }
}
```

#### Keycloak-specific Configuration

When using Keycloak as your identity provider:

1. Create a SAML client in Keycloak for Terraform Enterprise
2. Configure the client to include role memberships in SAML assertions
3. The `team_membership_attribute` should be set to "Roles" when using Keycloak roles
4. Use Keycloak Role IDs as the SSO Team IDs in your configuration

For more details, see the [SSO Integration Module README](./modules/sso-integration/README.md).

## Best Practices

- Use the provided modules for consistency
- Keep team-specific configurations in dedicated directories
- Use variable sets for platform-specific configurations
- Regularly update and test the codebase
- Follow the recommended workflow for state management
- Use CI/CD pipelines for automated validation and deployment