# Preprod Environment Configuration

# Environment-specific configurations
environment_configs = {
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
  }
}

# Platform-specific configurations for preprod environment
vsphere_config = {
  enabled     = true
  datacenter  = "dc-preprod-01"
  cluster     = "cluster-preprod-01"
  datastore   = "datastore-preprod-01"
  network     = "network-preprod-01"
  folder_path = "/vm/terraform-managed-preprod"
}

aws_config = {
  enabled     = true
  region      = "us-west-2"
  account_id  = "123456789012"
  vpc_id      = "vpc-preprod0123456789abcdef"
  subnet_ids  = ["subnet-preprod0123456789abcdef0", "subnet-preprod0123456789abcdef1"]
}

azure_config = {
  enabled         = true
  subscription_id = "00000000-0000-0000-0000-000000000001"
  resource_group  = "terraform-preprod-resources"
  location        = "eastus"
  virtual_network = "terraform-preprod-vnet"
  subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/terraform-preprod-resources/providers/Microsoft.Network/virtualNetworks/terraform-preprod-vnet/subnets/default"
} 