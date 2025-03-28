variable "organization" {
  description = "The name of the TFE organization"
  type        = string
}

variable "team_config" {
  description = "Configuration for the team"
  type = object({
    name        = string
    description = string
    email       = string
    cost_code   = string
    platforms   = list(string)
    environments = list(string)
    admins      = list(string)
    members     = list(string)
  })
}

variable "environments" {
  description = "List of environments to create projects for"
  type        = list(string)
  default     = ["dev", "preprod", "prod"]
}

variable "platforms" {
  description = "List of platforms this team will use (vsphere, aws, azure)"
  type        = list(string)
  validation {
    condition = alltrue([
      for platform in var.platforms : 
      contains(["vsphere", "aws", "azure"], platform)
    ])
    error_message = "Platforms must be one of: vsphere, aws, azure."
  }
}

variable "platform_varset_ids" {
  description = "Map of platform names to their variable set IDs"
  type = object({
    vsphere = string
    aws     = string
    azure   = string
  })
  default = {
    vsphere = null
    aws     = null
    azure   = null
  }
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