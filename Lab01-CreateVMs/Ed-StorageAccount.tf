# # Create New Storage Account
# resource "azurerm_storage_account" "StorageAccount" {
#   name                     = "sa${lower(replace(var.prefix, "-", ""))}"
#   resource_group_name      = azurerm_resource_group.ResourceGroup.name
#   location                 = var.LocationDefault
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
#   tags                     = merge(var.tagsDefault, var.tagsFinance)
# }

# resource "azurerm_storage_container" "StorageContainer" {
#   count                 = 2
#   name                  = "sc${lower(replace(var.prefix, "-", ""))}${count.index}"
#   storage_account_name  = azurerm_storage_account.StorageAccount.name
#   container_access_type = "private"

# }