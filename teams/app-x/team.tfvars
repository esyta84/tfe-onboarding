teams = {
  "app-x" = {
    name        = "app-x"
    description = "Application X team workspaces"
    email       = "app-x-team@example.com"
    cost_code   = "CC-APP-X-456"
    platforms   = ["aws", "azure", "vsphere"]
    environments = ["dev", "preprod", "prod"]
    admins      = ["app-x-lead@example.com"]
    members     = ["app-x-dev1@example.com", "app-x-dev2@example.com", "app-x-ops@example.com"]
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