variable "organization" {
  description = "The name of the TFE organization"
  type        = string
}

variable "enable_team_management" {
  description = "Whether to enable team management via SAML assertions"
  type        = bool
  default     = true
}

variable "team_membership_attribute" {
  description = "The SAML attribute name to use for team membership mapping"
  type        = string
  default     = "MemberOf"
}

variable "sso_configuration" {
  description = "Configuration for SSO integration"
  type = object({
    provider_type = string # "okta", "azure_ad", "keycloak", "keycloak_redhat", or "generic_saml"
    
    # For Okta
    okta_metadata_url = optional(string)
    
    # For Azure AD
    azure_ad_metadata_url = optional(string)
    
    # For Keycloak (standard)
    keycloak_metadata_url = optional(string)
    keycloak_client_id    = optional(string)
    keycloak_realm        = optional(string)
    
    # For Red Hat build of Keycloak
    keycloak_redhat_metadata_url = optional(string)
    keycloak_redhat_client_id    = optional(string)
    keycloak_redhat_realm        = optional(string)
    
    # For generic SAML
    saml_idp_metadata = optional(string)
    saml_sso_url      = optional(string)
    saml_certificate  = optional(string)
  })
  
  validation {
    condition = contains(["okta", "azure_ad", "keycloak", "keycloak_redhat", "generic_saml"], var.sso_configuration.provider_type)
    error_message = "Provider type must be one of: okta, azure_ad, keycloak, keycloak_redhat, generic_saml."
  }
  
  validation {
    condition = (
      var.sso_configuration.provider_type == "okta" && var.sso_configuration.okta_metadata_url != null ||
      var.sso_configuration.provider_type == "azure_ad" && var.sso_configuration.azure_ad_metadata_url != null ||
      var.sso_configuration.provider_type == "keycloak" && 
      var.sso_configuration.keycloak_metadata_url != null && 
      var.sso_configuration.keycloak_client_id != null && 
      var.sso_configuration.keycloak_realm != null ||
      var.sso_configuration.provider_type == "keycloak_redhat" && 
      var.sso_configuration.keycloak_redhat_metadata_url != null && 
      var.sso_configuration.keycloak_redhat_client_id != null && 
      var.sso_configuration.keycloak_redhat_realm != null ||
      var.sso_configuration.provider_type == "generic_saml" && 
      var.sso_configuration.saml_idp_metadata != null && 
      var.sso_configuration.saml_sso_url != null && 
      var.sso_configuration.saml_certificate != null
    )
    error_message = "Required SSO configuration attributes missing for the selected provider type."
  }
}

variable "teams" {
  description = "List of teams to create SSO Team IDs for (mapping from AD Group IDs or Keycloak roles to TFE Team names)"
  type = map(object({
    name            = string
    sso_team_id     = string # This should be the Active Directory Group ID/UUID or Keycloak role ID
  }))
  default = {}
} 