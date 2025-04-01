provider "tfe" {
  organization = "your-organization-name" # Replace with your org name
}

variables {
  admin_team_name = "admins-test"
  user_team_name  = "users-test"
  application_id  = "my-app"
  tfe_organization = "your-organization-name" # Replace with your org name
}

run "setup" {
  module {
    source = "./tests/testing/setup"
  }
}

# Test that an incomplete environment list without prod is rejected
run "invalid_environment_landscape_missing_prod" {
  command = plan

  variables {
    environment_names = ["dev", "preprod"]
    admin_team_name   = var.admin_team_name
    user_team_name    = var.user_team_name
    application_id    = var.application_id
    tfe_organization  = var.tfe_organization
  }

  expect_failures = [var.environment_names]
}

# Test that an environment list with incorrect prod name is rejected
run "invalid_environment_landscape_incorrect_prod_name" {
  command = plan

  variables {
    environment_names = ["dev", "preprod", "production"]
    admin_team_name   = var.admin_team_name
    user_team_name    = var.user_team_name
    application_id    = var.application_id
    tfe_organization  = var.tfe_organization
  }

  expect_failures = [var.environment_names]
}

# Test that a valid environment list is accepted
run "valid_environment_landscape" {
  command = plan

  variables {
    environment_names = ["dev", "preprod", "prod"]
    admin_team_name   = var.admin_team_name
    user_team_name    = var.user_team_name
    application_id    = var.application_id
    tfe_organization  = var.tfe_organization
  }
}

# Test that workspace names are converted to lowercase
run "workspace_name_in_lowercase" {
  command = plan

  variables {
    environment_names = ["Dev", "Preprod", "Prod"]
    admin_team_name   = var.admin_team_name
    user_team_name    = var.user_team_name
    application_id    = "My-App"
    tfe_organization  = var.tfe_organization
  }

  assert {
    condition     = alltrue([for ws in tfe_workspace.workspace : lower(ws.name) == ws.name if ws != null])
    error_message = "All workspace names must be in lowercase."
  }
} 