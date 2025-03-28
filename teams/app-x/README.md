# App-X Team Terraform Configuration

This directory contains the Terraform configuration for the App-X team workspaces and resources.

## Overview

The App-X team uses this Terraform configuration to manage their infrastructure across development, pre-production, and production environments, using AWS, Azure, and vSphere platforms.

## Structure

```
app-x/
├── README.md                     # This file
├── main.tf                       # Main configuration for team onboarding
├── variables.tf                  # Variable declarations
├── outputs.tf                    # Output declarations
├── team.tfvars                   # Team-specific variable values
├── workspaces/                   # Environment-specific workspaces
│   ├── dev/                      # Development environment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── preprod/                  # Pre-production environment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── prod/                     # Production environment
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── platform-config/              # Platform-specific configurations
    ├── aws.tf                    # AWS-specific resources
    ├── azure.tf                  # Azure-specific resources
    └── vsphere.tf                # vSphere-specific resources
```

## Usage

### Team Onboarding

To onboard the App-X team infrastructure:

```bash
# Navigate to the team directory
cd teams/app-x

# Initialize Terraform
terraform init

# Plan the changes
terraform plan -var-file="team.tfvars"

# Apply the changes
terraform apply -var-file="team.tfvars"
```

### Environment-Specific Deployments

To deploy resources for a specific environment:

```bash
# Navigate to the environment directory
cd teams/app-x/workspaces/dev

# Initialize Terraform
terraform init

# Plan the changes
terraform plan

# Apply the changes
terraform apply
```

## Team Settings

- **Team Name**: App-X
- **Description**: Application X team workspaces
- **Email**: app-x-team@example.com
- **Cost Code**: CC-APP-X-456
- **Platforms**: AWS, Azure, vSphere
- **Environments**: Development, Pre-production, Production

## SSO Configuration

The App-X team uses Keycloak for identity management with the following roles:

- Administrator role: App-X-Administrators (Keycloak role ID: a1b2c3d4-e5f6-0000-0000-000000000010)
- Developer role: App-X-Developers (Keycloak role ID: a1b2c3d4-e5f6-0000-0000-000000000011)
- Operator role: App-X-Operators (Keycloak role ID: a1b2c3d4-e5f6-0000-0000-000000000012)

## Workspace Management

Team App-X uses separate workspaces for each environment to ensure proper isolation:

- **Development**: For feature development and testing
- **Pre-production**: For integration testing and UAT
- **Production**: For live customer-facing systems

Each workspace has specific permission levels assigned based on environment sensitivity. 