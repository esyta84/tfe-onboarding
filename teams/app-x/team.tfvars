team_config = {
  name        = "app-x"
  description = "Application X Team"
  email       = "appx-team@example.com"
  cost_code   = "CC-APP-X-123"
  platforms   = ["aws", "azure", "vsphere"]
  environments = ["dev", "preprod", "prod"]
  
  # Emergency/fallback admin accounts only
  fallback_admins = ["emergency-admin@example.com"]
  
  # Regular members will be managed exclusively via SSO
  # members = [] # Empty or omitted
  
  # Per-environment AWS configuration
  aws_config = {
    dev = {
      region     = "us-west-2"
      account_id = "111111111111"
      vpc_id     = "vpc-dev1234"
      subnet_ids = ["subnet-dev1", "subnet-dev2", "subnet-dev3"]
    }
    preprod = {
      region     = "us-west-2"
      account_id = "222222222222"
      vpc_id     = "vpc-preprod1234"
      subnet_ids = ["subnet-preprod1", "subnet-preprod2", "subnet-preprod3"]
    }
    prod = {
      region     = "us-west-2"
      account_id = "333333333333"
      vpc_id     = "vpc-prod1234"
      subnet_ids = ["subnet-prod1", "subnet-prod2", "subnet-prod3"]
    }
  }
  
  # Per-environment Azure configuration
  azure_config = {
    dev = {
      location       = "eastus"
      subscription_id = "11111111-1111-1111-1111-111111111111"
      resource_group = "app-x-dev-rg"
      vnet_name      = "app-x-dev-vnet"
      subnet_names   = ["app-subnet", "data-subnet"]
    }
    preprod = {
      location       = "eastus"
      subscription_id = "22222222-2222-2222-2222-222222222222"
      resource_group = "app-x-preprod-rg"
      vnet_name      = "app-x-preprod-vnet"
      subnet_names   = ["app-subnet", "data-subnet"]
    }
    prod = {
      location       = "eastus"
      subscription_id = "33333333-3333-3333-3333-333333333333"
      resource_group = "app-x-prod-rg"
      vnet_name      = "app-x-prod-vnet"
      subnet_names   = ["app-subnet", "data-subnet"]
    }
  }
  
  # Per-environment vSphere configuration
  vsphere_config = {
    dev = {
      vsphere_server  = "vcenter-dev.example.com"
      datacenter      = "DC-DEV"
      compute_cluster = "CL-DEV-APP"
      datastore       = "DS-DEV-APP"
      resource_pool   = "RP-DEV-APP-X"
      folder          = "FD-DEV-APP-X"
      network         = "NET-DEV-APP"
    }
    preprod = {
      vsphere_server  = "vcenter-preprod.example.com"
      datacenter      = "DC-PREPROD"
      compute_cluster = "CL-PREPROD-APP"
      datastore       = "DS-PREPROD-APP"
      resource_pool   = "RP-PREPROD-APP-X"
      folder          = "FD-PREPROD-APP-X"
      network         = "NET-PREPROD-APP"
    }
    prod = {
      vsphere_server  = "vcenter-prod.example.com"
      datacenter      = "DC-PROD"
      compute_cluster = "CL-PROD-APP"
      datastore       = "DS-PROD-APP"
      resource_pool   = "RP-PROD-APP-X"
      folder          = "FD-PROD-APP-X"
      network         = "NET-PROD-APP"
    }
  }
}

# SSO team mappings for app-x
sso_team_mappings = {
  app_x_admins = {
    name = "App-X-Administrators"
    sso_team_id = "a1b2c3d4-e5f6-0000-0000-000000000010"  # Keycloak role ID for app-x admins
  },
  app_x_developers = {
    name = "App-X-Developers"
    sso_team_id = "a1b2c3d4-e5f6-0000-0000-000000000011"  # Keycloak role ID for app-x developers
  },
  app_x_operators = {
    name = "App-X-Operators"
    sso_team_id = "a1b2c3d4-e5f6-0000-0000-000000000012"  # Keycloak role ID for app-x operators
  }
} 