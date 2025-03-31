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
    enabled     = false
    datacenter  = ""
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
    account_id  = string
    vpc_id      = string
    subnet_ids  = list(string)
  })
  default = {
    enabled     = false
    region      = "ap-southeast-2"
    account_id  = ""
    vpc_id      = ""
    subnet_ids  = []
  }
}

variable "azure_config" {
  description = "Configuration for Azure environments"
  type = object({
    enabled           = bool
    subscription_id   = string
    resource_group    = string
    location          = string
    virtual_network   = string
    subnet_id         = string
  })
  default = {
    enabled           = false
    subscription_id   = ""
    resource_group    = ""
    location          = "eastus"
    virtual_network   = ""
    subnet_id         = ""
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
  description = "Configuration for the SSO provider integration"
  type = object({
    provider_type = string
    
    # Optional Okta configuration
    okta_metadata_url = optional(string)
    
    # Optional Azure AD configuration
    azure_ad_metadata_url = optional(string)
    
    # Optional Generic SAML configuration
    saml_idp_metadata = optional(string)
    saml_sso_url      = optional(string)
    saml_certificate  = optional(string)
  })
  
  default = {
    provider_type = "none"
  }

  validation {
    condition     = contains(["none", "okta", "azure_ad", "generic_saml"], var.sso_configuration.provider_type)
    error_message = "Provider type must be one of: 'none', 'okta', 'azure_ad', 'generic_saml'."
  }
  
  validation {
    condition     = var.sso_configuration.provider_type != "okta" || var.sso_configuration.okta_metadata_url != null
    error_message = "When provider_type is 'okta', okta_metadata_url must be provided."
  }
  
  validation {
    condition     = var.sso_configuration.provider_type != "azure_ad" || var.sso_configuration.azure_ad_metadata_url != null
    error_message = "When provider_type is 'azure_ad', azure_ad_metadata_url must be provided."
  }
  
  validation {
    condition     = var.sso_configuration.provider_type != "generic_saml" || (
                     var.sso_configuration.saml_idp_metadata != null &&
                     var.sso_configuration.saml_sso_url != null &&
                     var.sso_configuration.saml_certificate != null
                   )
    error_message = "When provider_type is 'generic_saml', all of saml_idp_metadata, saml_sso_url, and saml_certificate must be provided."
  }
}

variable "sso_team_mappings" {
  description = "Map of teams to create with SSO Team IDs for Active Directory group mapping"
  type = map(object({
    name        = string
    sso_team_id = string
  }))
  default = {}
} 