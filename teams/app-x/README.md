# App-X Team Terraform Configuration

This directory contains the Terraform configuration for the App-X team workspaces and resources.

## Overview

The App-X team uses this Terraform configuration to manage their infrastructure across development, pre-production, and production environments, using AWS as the cloud platform.

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
    └── aws.tf                    # AWS-specific resources
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
- **Platforms**: AWS
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

## AWS Configuration

The App-X team has environment-specific AWS configurations:

- **Development**:
  - AWS Account: 111111111111
  - Region: ap-southeast-2
  - VPC: vpc-dev111111111111
  - Subnets: subnet-dev1111111, subnet-dev2222222

- **Pre-production**:
  - AWS Account: 222222222222
  - Region: ap-southeast-2
  - VPC: vpc-preprod22222222
  - Subnets: subnet-preprod1111, subnet-preprod2222

- **Production**:
  - AWS Account: 333333333333
  - Region: ap-southeast-2
  - VPC: vpc-prod3333333333
  - Subnets: subnet-prod1111111, subnet-prod2222222 