
# Create Resource Groups - 
resource "azurerm_resource_group" "ResourceGroup" {
  count = length(var.Locations)
  name  = "RG-TF-${element(var.prefix, count.index)}"
  # name     = "RG-${var.prefix}-${var.prefixUKS}"
  location = element(var.Locations, count.index)
  tags     = merge(var.tagsDefault, var.tagsFinance)

}

#Import UKS Resource Group


# # Create New Resource Group - UKSouth
# resource "azurerm_resource_group" "ResourceGroupUKS" {
#   name     = "RG-${var.prefix}-${var.prefixUKS}"
#   location = var.LocationUKS
#   tags     = merge(var.tagsDefault, var.tagsFinance)

# }

# # Create New Resource Group - North Europe
# resource "azurerm_resource_group" "ResourceGroupNE" {
#   name     = "RG-${var.prefix}-${var.prefixNE}"
#   location = var.LocationNE
#   tags     = merge(var.tagsDefault, var.tagsFinance)

# }

# # Create New Resource Group
# resource "azurerm_resource_group" "ResourceGroupWVD" {
#   name     = "WVD-RG-${var.prefix}"
#   location = var.LocationWVD
#   tags     = merge(var.tagsDefault, var.tagsFinance, var.tagsWVD)

# }