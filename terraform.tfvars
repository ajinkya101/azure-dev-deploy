rg_name              = "devrg01"
region               = "canadacentral"
storage_account_name = "stg737047"
network_rules = {
  bypass     = ["AzureServices"]
  ip_rules   = []
  subnet_ids = []
}
tags = {
  "owner" = "master"
}