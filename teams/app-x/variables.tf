# Variables for App-X team configuration

variable "teams" {
  description = "Map of teams to be onboarded with their configurations"
  type = map(object({
    name        = string
    description = string
    email       = string
    cost_code   = string
    platforms   = list(string)
    environments = list(string)
    admins      = list(string)
    members     = list(string)
  }))
}

variable "sso_team_mappings" {
  description = "Map of teams to create with SSO Team IDs for identity provider group/role mapping"
  type = map(object({
    name        = string
    sso_team_id = string
  }))
}

# Root module required variables
variable "tfe_organization" {
  description = "Name of the Terraform Enterprise organization"
  type        = string
}

variable "tfe_token" {
  description = "The API token for authenticating to Terraform Enterprise"
  type        = string
  sensitive   = true
}

variable "tfe_org_email" {
  description = "Email address for the Terraform Enterprise organization"
  type        = string
}

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
    run_operation_timeout     = number
    workspace_name_prefix     = string
  }))
}

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
}

variable "enable_sso_team_management" {
  description = "Whether to enable team management via SAML assertions"
  type        = bool
}

variable "sso_team_membership_attribute" {
  description = "The name of the SAML attribute containing team membership information"
  type        = string
}

variable "sso_configuration" {
  description = "Configuration for the SSO provider integration"
  type = object({
    provider_type = string
    
    # Optional Okta configuration
    okta_metadata_url = optional(string)
    
    # Optional Azure AD configuration
    azure_ad_metadata_url = optional(string)
    
    # Optional Keycloak configuration
    keycloak_metadata_url = optional(string)
    keycloak_client_id    = optional(string)
    keycloak_realm        = optional(string)
    
    # Optional Red Hat Keycloak configuration
    keycloak_redhat_metadata_url = optional(string)
    keycloak_redhat_client_id    = optional(string)
    keycloak_redhat_realm        = optional(string)
    
    # Optional Generic SAML configuration
    saml_idp_metadata = optional(string)
    saml_sso_url      = optional(string)
    saml_certificate  = optional(string)
  })
}

variable "admin_team" {
  description = "Configuration for the platform admin team"
  type = object({
    name        = string
    description = string
    admins      = list(string)
    members     = list(string)
  })
}

variable "admin_projects" {
  description = "List of administrative projects to create"
  type = list(object({
    name        = string
    description = string
  }))
} 