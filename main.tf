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