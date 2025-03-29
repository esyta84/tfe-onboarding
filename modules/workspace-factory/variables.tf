variable "organization" {
  description = "The name of the TFE organization"
  type        = string
}

variable "team_name" {
  description = "Name of the team"
  type        = string
}

variable "team_projects" {
  description = "Map of environment names to their project IDs"
  type        = map(string)
}

variable "environments" {
  description = "List of environments to create workspaces for"
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

variable "team_variables" {
  description = "Map of team-specific variables to be set on workspaces"
  type        = map(string)
  default     = {}
}

variable "aws_team_config" {
  description = "Team-specific AWS configuration per environment that overrides the global AWS config"
  type        = map(any)
  default     = null
}

variable "azure_team_config" {
  description = "Team-specific Azure configuration per environment that overrides the global Azure config"
  type        = map(any)
  default     = null
}

variable "vsphere_team_config" {
  description = "Team-specific vSphere configuration per environment that overrides the global vSphere config"
  type        = map(any)
  default     = null
}

variable "platform_workspace_count" {
  description = "Number of workspaces to create per platform"
  type = map(object({
    vsphere = number
    aws     = number
    azure   = number
  }))
  default = {
    dev = {
      vsphere = 1
      aws     = 1
      azure   = 1
    }
    preprod = {
      vsphere = 1
      aws     = 1
      azure   = 1
    }
    prod = {
      vsphere = 1
      aws     = 1
      azure   = 1
    }
  }
} 