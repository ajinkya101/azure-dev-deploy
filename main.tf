#------------------------------
# Create a Azure resource group
#------------------------------

module "rg01" {
  source = "git::https://github.com/ajinkya101/azure-rg-module.git?ref=v0.0.1"
  #checkov:skip=CKV_TF_1 "Ensure Terraform module sources use a commit hash" Not Required
  rg_name = var.rg_name
  region  = var.region
  tags    = var.tags
}

module "stg01" {
  source = "git::https://github.com/ajinkya101/azure-storage-account-module.git?ref=v0.0.2"
  #checkov:skip=CKV_TF_1 "Ensure Terraform module sources use a commit hash" Not Required
  rg_name              = module.rg01.rg_name
  location             = module.rg01.rg_location
  storage_account_name = var.storage_account_name
  network_rules        = var.network_rules
  tags                 = var.tags
}

# ------------------------------------------------
# Azure Virtual Network Module is called here
# ------------------------------------------------
module "vnet1" {
  source                        = "./modules/vnet"
  rg_name                       = module.rg01.rg_name
  location                      = module.rg01.rg_location
  vnet_name                     = "dev-vnet"
  vnet_address_space            = ["10.10.0.0/16"]
  gateway_subnet_address_prefix = ["10.10.1.0/27"]
  subnets = {
    ComputeSubnet = {
      subnet_name           = "ComputeSubnet"
      subnet_address_prefix = ["10.10.2.0/24"]

      nsg_inbound_rules = [
        ["ssh_rule", "105", "Inbound", "Allow", "Tcp", "22", "*", "*"],
        ["http_rule", "106", "Inbound", "Allow", "Tcp", "80", "*", "*"],
      ]
    }
  }
  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "law01" {
  name                = "lawqctest-01"
  location            = module.rg01.rg_location
  resource_group_name = module.rg01.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# -------------------------------------------
# Azure Virtual Machine Module is called here
# -------------------------------------------
module "virtual-machine" {
  source = "./modules/vm"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = module.rg01.rg_name
  location             = module.rg01.rg_location
  virtual_network_name = "dev-vnet"
  subnet_name          = "ComputeSubnet"
  virtual_machine_name = "win-machine01"

  # This module support multiple Pre-Defined Linux and Windows Distributions.
  # Check the README.md file for more pre-defined images for WindowsServer, MSSQLServer.
  # Please make sure to use gen2 images supported VM sizes if you use gen2 distributions
  # This module creates a random admin password if `admin_password` is not specified
  # Specify a valid password with `admin_password` argument to use your own password 
  os_flavor                 = "windows"
  windows_distribution_name = "windows2019dc"
  virtual_machine_size      = "Standard_A2_v2"
  admin_username            = "azureadmin"
  admin_password            = "P@$$w0rd1234!"
  instances_count           = 1

  # Proxymity placement group, Availability Set and adding Public IP to VM's are optional.
  # remove these argument from module if you dont want to use it.  
  enable_proximity_placement_group = false
  enable_vm_availability_set       = false
  enable_public_ip_address         = true

  # Network Seurity group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.
  # Remove this NSG rules block, if `existing_network_security_group_id` is specified
  existing_network_security_group_id = null

  # Boot diagnostics to troubleshoot virtual machines, by default uses managed 
  # To use custom storage account, specify `storage_account_name` with a valid name
  # Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics
  enable_boot_diagnostics = true

  # Attach a managed data disk to a Windows/Linux VM's. Possible Storage account type are: 
  # `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `Premium_ZRS`, `StandardSSD_LRS`
  # or `UltraSSD_LRS` (UltraSSD_LRS only available in a region that support availability zones)
  # Initialize a new data disk - you need to connect to the VM and run diskmanagemnet or fdisk
  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 200
      storage_account_type = "Standard_LRS"
    }
  ]

  # (Optional) To enable Azure Monitoring and install log analytics agents
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage.   
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law01.id

  # Deploy log analytics agents to virtual machine. 
  # Log analytics workspace customer id and primary shared key required.
  deploy_log_analytics_agent                 = true
  log_analytics_customer_id                  = azurerm_log_analytics_workspace.law01.workspace_id
  log_analytics_workspace_primary_shared_key = azurerm_log_analytics_workspace.law01.primary_shared_key

  # Adding additional TAG's to your Azure resources
  tags = {
    ProjectName  = "demo-project"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }

  depends_on = [module.vnet1]
}

# module "web_app" {
#   source = "./modules/Windows_Web_App"

#   resource_group             = module.rg01.rg_name
#   location                   = module.rg01.rg_location
#   service_plan               = "web-win-plan"
#   web_app                    = "web-win-app-001"
#   app_log_categories         = var.app_log_categories
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.law01.id
#   enable_audit_log_analytics = true
# }

# module "mssql" {
#   source = "./modules/mssql"

#   resource_group             = module.rg01.rg_name
#   mssql_server               = var.mssql_server
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.law01.id
#   enable_audit_log_analytics = true
# }

# resource "azurerm_mssql_server_extended_auditing_policy" "audit" {
#   server_id              = data.azurerm_mssql_server.sql.id
#   log_monitoring_enabled = true
# }

# resource "azurerm_monitor_diagnostic_setting" "sqldiag" {
#   name                       = "sql-diagnotic-setting"
#   target_resource_id         = "${data.azurerm_mssql_server.sql.id}/databases/master"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.law01.id

#   enabled_log {
#     category = "SQLSecurityAuditEvents"
#   }
# }

# resource "azurerm_monitor_diagnostic_setting" "diag_settings_app" {
#   name                       = "sql-db-diag-rule-01"
#   target_resource_id         = data.azurerm_mssql_database.sqldb.id
#   log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law01.id

#   enabled_log {
#     category = "SQLInsights"
#   }
#   enabled_log {
#     category = "AutomaticTuning"
#   }
#   enabled_log {
#     category = "QueryStoreRuntimeStatistics"
#   }
#   enabled_log {
#     category = "QueryStoreWaitStatistics"
#   }
#   enabled_log {
#     category = "Errors"
#   }
#   enabled_log {
#     category = "DatabaseWaitStatistics"
#   }
#   enabled_log {
#     category = "Timeouts"
#   }
#   enabled_log {
#     category = "Deadlocks"
#   }
# }