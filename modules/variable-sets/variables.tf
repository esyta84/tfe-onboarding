variable "organization" {
  description = "The name of the TFE organization"
  type        = string
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