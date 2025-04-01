# Test file for team-foundation module

terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.64.0"
    }
  }
}

provider "tfe" {
  # Using dummy values for test - replace with real values when running
  hostname = "app.terraform.io"
  token    = "dummy-token"
}

# Test with empty platform_varset_ids to ensure it works at plan time
module "team_foundation_test" {
  source = "../../team-foundation"
  
  organization = "example-org"
  
  team_config = {
    name        = "test-team"
    description = "Test team for module validation"
    email       = "test@example.com"
    cost_code   = "TEST-123"
    platforms   = ["aws", "azure"]
    environments = ["dev", "prod"]
    admins      = ["admin@example.com"]
    members     = ["member@example.com"]
  }
  
  platforms = ["aws", "azure"]
  environments = ["dev", "prod"]
  
  # This is what we're testing - empty platform_varset_ids should not cause errors
  platform_varset_ids = {
    vsphere = ""
    aws     = ""
    azure   = ""
  }
  
  environment_configs = {
    dev = {
      auto_apply                = true
      terraform_version         = "1.6.0"
      execution_mode            = "remote"
      terraform_working_dir     = ""
      speculative_enabled       = true
      allow_destroy_plan        = true
      file_triggers_enabled     = true
      trigger_prefixes          = []
      queue_all_runs            = false
      assessments_enabled       = false
      global_remote_state       = false
      run_operation_timeout     = 30
      workspace_name_prefix     = "dev-"
    },
    prod = {
      auto_apply                = false
      terraform_version         = "1.6.0"
      execution_mode            = "remote"
      terraform_working_dir     = ""
      speculative_enabled       = true
      allow_destroy_plan        = false
      file_triggers_enabled     = true
      trigger_prefixes          = []
      queue_all_runs            = true
      assessments_enabled       = true
      global_remote_state       = true
      run_operation_timeout     = 120
      workspace_name_prefix     = "prod-"
    }
  }
}

# Output the project IDs to verify the module worked
output "project_ids" {
  value = module.team_foundation_test.project_ids
}
