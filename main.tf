#------------------------------
# Create a Azure resource group
#------------------------------
#Skipping Chcekov checks
#checkov:skip=CKV_TF_1 "Ensure Terraform module sources use a commit hash" Not Required

module "rg01" {
  source  = "git::https://github.com/ajinkya101/azure-rg-module.git?ref=v0.0.1"
  rg_name = var.rg_name
  region  = var.region
  tags    = var.tags
}

module "stg01" {
  source               = "git::https://github.com/ajinkya101/azure-storage-account-module.git?ref=v0.0.1"
  rg_name              = var.rg_name
  region               = var.region
  storage_account_name = var.storage_account_name
  network_rules        = var.network_rules
  tags                 = var.tags
}
