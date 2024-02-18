#------------------------------
# Create a Azure resource group
#------------------------------
module "rg01" {
  source = "git::https://github.com/ajinkya101/azure-rg-module.git?ref=v0.0.1"

  rg_name = var.rg_name
  region  = var.region
  tags    = var.tags
}