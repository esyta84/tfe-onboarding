# Environment-Specific Platform Configurations

This document explains how to configure separate accounts, subscriptions, and datastores for each environment (dev, preprod, prod) in your Terraform Enterprise onboarding automation.

## Overview

Each team can have separate:
- AWS accounts
- Azure subscriptions
- vSphere configurations

For each environment they use (dev, preprod, prod).

## Configuration Structure

In your `terraform.tfvars` file, you can specify per-environment configurations for each team:

```hcl
teams = {
  "team-name" = {
    # Standard team details
    name        = "team-name"
    description = "Team Description"
    email       = "team@example.com"
    cost_code   = "CC-TEAM-123"
    platforms   = ["aws", "azure", "vsphere"]
    environments = ["dev", "preprod", "prod"]
    admins      = ["admin@example.com"]
    members     = ["member@example.com"]
    
    # Environment-specific AWS configurations
    aws_config = {
      dev = {
        region      = "ap-southeast-2"
        account_id  = "111111111111"
        vpc_id      = "vpc-dev111111111111"
        subnet_ids  = ["subnet-dev1", "subnet-dev2"]
      },
      preprod = {
        region      = "ap-southeast-2" 
        account_id  = "222222222222"
        vpc_id      = "vpc-preprod2222222"
        subnet_ids  = ["subnet-preprod1", "subnet-preprod2"]
      },
      prod = {
        region      = "ap-southeast-2"
        account_id  = "333333333333"
        vpc_id      = "vpc-prod33333333"
        subnet_ids  = ["subnet-prod1", "subnet-prod2"]
      }
    },
    
    # Environment-specific Azure configurations
    azure_config = {
      dev = {
        subscription_id = "00000000-0000-0000-0000-000000000001"
        resource_group  = "team-dev-rg"
        location        = "australiaeast"
      },
      preprod = {
        subscription_id = "00000000-0000-0000-0000-000000000002"
        resource_group  = "team-preprod-rg"
        location        = "australiaeast"
      },
      prod = {
        subscription_id = "00000000-0000-0000-0000-000000000003"
        resource_group  = "team-prod-rg"
        location        = "australiaeast"
      }
    },
    
    # Environment-specific vSphere configurations
    vsphere_config = {
      dev = {
        datacenter  = "dc-01"
        cluster     = "cluster-dev"
        datastore   = "datastore-dev"
        network     = "network-dev"
        folder_path = "/vm/terraform-managed/team/dev"
      },
      preprod = {
        datacenter  = "dc-01"
        cluster     = "cluster-preprod"
        datastore   = "datastore-preprod"
        network     = "network-preprod"
        folder_path = "/vm/terraform-managed/team/preprod"
      },
      prod = {
        datacenter  = "dc-02"
        cluster     = "cluster-prod"
        datastore   = "datastore-prod"
        network     = "network-prod"
        folder_path = "/vm/terraform-managed/team/prod"
      }
    }
  }
}
```

## Implementation Details

When a team is onboarded:

1. Each environment (dev, preprod, prod) gets its own project in Terraform Enterprise
2. Each platform (AWS, Azure, vSphere) gets its own workspace within each project
3. Per-environment configuration values are injected as variables into each workspace
4. The correct credentials for each environment are used automatically

## Best Practices

1. **Isolation**: Keep production accounts completely separate from non-production
2. **Consistency**: Use similar naming patterns across all environments
3. **Least Privilege**: Grant only the necessary permissions for each environment
4. **Documentation**: Keep a record of all account IDs and their purposes

## Security Considerations

- Store actual credentials (API keys, tokens) in Terraform Enterprise variable sets, not in code
- Use provider configurations with assume_role for AWS
- Consider setting up trust relationships between accounts rather than storing credentials
- Use Azure managed identities where possible
- Implement more restrictive policies for production environments 