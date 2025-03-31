###################################################
# Global TFE Configuration Variables
###################################################

variable "tfe_hostname" {
  description = "The hostname of the Terraform Enterprise instance"
  type        = string
  default     = "app.terraform.io"
}

variable "tfe_token" {
  description = "The API token for authenticating to Terraform Enterprise"
  type        = string
  sensitive   = true
}

variable "tfe_organization" {
  description = "Name of the Terraform Enterprise organization"
  type        = string
}

variable "tfe_org_email" {
  description = "Email address for the Terraform Enterprise organization"
  type        = string
  default     = "admin@example.com"
}

###################################################
# Team Onboarding Variables
###################################################

variable "teams" {
  description = "Map of teams to be onboarded with their configurations"
  type = map(object({
    name        = string
    description = string
    email       = string
    cost_code   = string
    platforms   = list(string) # List of platforms the team will use: "vsphere", "aws", "azure"
    environments = list(string) # By default, this is ["dev", "preprod", "prod"], but can be customized
    admins      = list(string) # List of team admin email addresses
    members     = list(string) # List of team member email addresses
  }))
  default = {}
}

###################################################
# Platform Configuration Variables
###################################################

variable "vsphere_config" {
  description = "Configuration for vSphere environments"
  type = object({
    enabled     = bool
    datacenter  = string
    cluster     = string
    datastore   = string
    network     = string
    folder_path = string
  })
  default = {
    enabled     = true
    datacenter  = "dc-01"
    cluster     = ""
    datastore   = ""
    network     = ""
    folder_path = ""
  }
}

variable "aws_config" {
  description = "Configuration for AWS environments"
  type = object({
    enabled     = bool
    region      = string
    account_id  = optional(string)
    vpc_id      = optional(string)
    subnet_ids  = optional(list(string), [])
  })
  default = {
    enabled     = false
    region      = "ap-southeast-2"
  }
}

variable "azure_config" {
  description = "Configuration for Azure environments"
  type = object({
    enabled           = bool
    location          = optional(string, "australiaeast")
    subscription_id   = optional(string)
    resource_group    = optional(string)
    virtual_network   = optional(string)
    subnet_id         = optional(string)
  })
  default = {
    enabled = false
    # Optional fields don't need defaults in this block
  }
}

###################################################
# Administrative Configuration
###################################################

variable "admin_team" {
  description = "Configuration for the platform admin team"
  type = object({
    name        = string
    description = string
    admins      = list(string)
    members     = list(string)
  })
  default = {
    name        = "platform-admins"
    description = "Team responsible for managing TFE platform"
    admins      = []
    members     = []
  }
}

variable "admin_projects" {
  description = "List of administrative projects to create"
  type = list(object({
    name        = string
    description = string
  }))
  default = [
    {
      name        = "platform-management"
      description = "For managing the TFE platform itself"
    },
    {
      name        = "workspace-provisioning"
      description = "For automating workspace creation"
    }
  ]
}

###################################################
# Environment Configuration
###################################################

variable "environment_configs" {
  description = "Configuration for different environments"
  type = map(object({
    auto_apply                = bool
    terraform_version         = string
    execution_mode            = string
    terraform_working_dir     = string
    speculative_enabled       = bool
    allow_destroy_plan        = bool
    file_triggers_enabled     = bool
    trigger_prefixes          = list(string)
    queue_all_runs            = bool
    assessments_enabled       = bool
    global_remote_state       = bool
    run_operation_timeout     = number # In minutes
    workspace_name_prefix     = string # Can be used to prefix workspace names
  }))
  default = {
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
    preprod = {
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
      run_operation_timeout     = 60
      workspace_name_prefix     = "preprod-"
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

###################################################
# SSO Integration Variables
###################################################

variable "enable_sso_team_management" {
  description = "Whether to enable team management via SAML assertions"
  type        = bool
  default     = false
}

variable "sso_team_membership_attribute" {
  description = "The name of the SAML attribute containing team membership information"
  type        = string
  default     = "MemberOf"
}

variable "sso_configuration" {
  description = "Configuration for the Keycloak SSO provider integration"
  type = object({
    provider_type = string
    
    # Keycloak configuration
    keycloak_metadata_url = optional(string)
    keycloak_client_id = optional(string)
    keycloak_realm = optional(string)
    
    # Red Hat Keycloak configuration
    keycloak_redhat_metadata_url = optional(string)
    keycloak_redhat_client_id = optional(string)
    keycloak_redhat_realm = optional(string)
  })
  
  default = {
    provider_type = "none"
  }

  validation {
    condition     = contains(["none", "keycloak", "keycloak_redhat"], var.sso_configuration.provider_type)
    error_message = "Provider type must be one of: 'none', 'keycloak', 'keycloak_redhat'."
  }
  
  validation {
    condition     = var.sso_configuration.provider_type != "keycloak" || (
                     var.sso_configuration.keycloak_metadata_url != null &&
                     var.sso_configuration.keycloak_client_id != null &&
                     var.sso_configuration.keycloak_realm != null
                   )
    error_message = "When provider_type is 'keycloak', all of keycloak_metadata_url, keycloak_client_id, and keycloak_realm must be provided."
  }
  
  validation {
    condition     = var.sso_configuration.provider_type != "keycloak_redhat" || (
                     var.sso_configuration.keycloak_redhat_metadata_url != null &&
                     var.sso_configuration.keycloak_redhat_client_id != null &&
                     var.sso_configuration.keycloak_redhat_realm != null
                   )
    error_message = "When provider_type is 'keycloak_redhat', all of keycloak_redhat_metadata_url, keycloak_redhat_client_id, and keycloak_redhat_realm must be provided."
  }
}

variable "sso_team_mappings" {
  description = "Map of teams to create with SSO Team IDs for Keycloak role mapping"
  type = map(object({
    name        = string
    sso_team_id = string
  }))
  default = {}
}

locals {
  # Only use account_id when provided
  aws_account_id = var.aws_config.account_id != null ? var.aws_config.account_id : ""
  
  # Only use vpc_id when provided
  aws_vpc_id = var.aws_config.vpc_id != null ? var.aws_config.vpc_id : ""
  
  # Use subnet_ids if provided, otherwise empty list
  aws_subnet_ids = var.aws_config.subnet_ids != null ? var.aws_config.subnet_ids : []
}