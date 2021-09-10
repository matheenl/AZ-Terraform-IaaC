

# Create VNets
resource "azurerm_virtual_network" "VNets" {
  count               = length(var.Locations)
  name                = "VNet-${element(var.prefix, count.index)}"
  location            = element(azurerm_resource_group.ResourceGroup.*.location, count.index)
  resource_group_name = element(azurerm_resource_group.ResourceGroup.*.name, count.index)
  address_space       = [element(var.VNetAddressSpace, count.index)]
  dns_servers         = [element(var.VNetDNSServers, count.index)]

  #dns_servers = [var.VNetDNSServers[0], var.VNetDNSServers[1]]
}

#Create Subnets
resource "azurerm_subnet" "Subnets" {
  count                = length(var.Locations) * length(var.VNetSubnetNames)
  name                 = "Subnet-${element(var.prefix, count.index)}-${element(var.VNetSubnetNames, count.index)}"
  resource_group_name  = element(azurerm_resource_group.ResourceGroup.*.name, count.index)
  virtual_network_name = element(azurerm_virtual_network.VNets.*.name, count.index)
  address_prefixes     = [element(var.VNetSubnets, count.index)]
  # Service endpoints - Required when doing mySQL or Cosmos DB demo or Azure AD etc
  service_endpoints = ["Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB", "Microsoft.ContainerRegistry", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Web"]

  #address_prefixes     = [cidrsubnet(element(azurerm_virtual_network.VNets[count.index].address_space, count.index, ), 8, 1, )]
  #address_prefix     = cidrsubnet(element(azurerm_virtual_network.VNets[count.index].address_space, count.index, ), 8, 1, ) # Address space + 8 resulting in /24 mask # 1 increments address space; 10.51.0.0/24


}

# Create Network Security Group - 
resource "azurerm_network_security_group" "NSG" {
  count               = length(var.Locations)
  name                = "NSG-${element(var.prefix, count.index)}"
  location            = element(azurerm_resource_group.ResourceGroup.*.location, count.index)
  resource_group_name = element(azurerm_resource_group.ResourceGroup.*.name, count.index)
  tags                = merge(var.tagsDefault, var.tagsFinance)

  dynamic "security_rule" {
    iterator = rule
    for_each = var.NetworkSecurityGroupRules
    content {
      name                       = rule.value.name
      priority                   = rule.value.priority
      direction                  = rule.value.direction
      access                     = rule.value.access
      protocol                   = rule.value.protocol
      source_port_range          = rule.value.source_port_range
      destination_port_range     = rule.value.destination_port_range
      source_address_prefix      = rule.value.source_address_prefix
      destination_address_prefix = rule.value.destination_address_prefix

    }

  }
}

# Associate subnets to security group
resource "azurerm_subnet_network_security_group_association" "NSGtoSubnet" {
  count                     = length(var.Locations)
  subnet_id                 = element(azurerm_subnet.Subnets.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.NSG.*.id, count.index)
}

# VNET Peering between UKS and NE VNETS
# enable global peering between the two virtual networks that will be created
# enable this only if two locations are referenced 
resource "azurerm_virtual_network_peering" "VNETpeering" {
  count                        = length(var.Locations)
  name                         = "peering-to-${element(azurerm_virtual_network.VNets.*.name, 1 - count.index)}"
  resource_group_name          = element(azurerm_resource_group.ResourceGroup.*.name, count.index)
  virtual_network_name         = element(azurerm_virtual_network.VNets.*.name, count.index)
  remote_virtual_network_id    = element(azurerm_virtual_network.VNets.*.id, 1 - count.index)
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet Global Peering
  allow_gateway_transit = false
}


# Use Data block to retrieve the existing RG and VNET where the domain controller resides. This is required to establish Peering. Otherwise the domain join will fail
data "azurerm_virtual_network" "UKSDCVNET" {
  name                = "VNET-UKS-Main"
  resource_group_name = "rg-uks-main"
}

data "azurerm_resource_group" "RGDCVNET" {
  name = "rg-uks-main"
}

# vNET Peering from the newly created VNETS to Domain Controller Existing VNET - VNET-UKS-Main
resource "azurerm_virtual_network_peering" "VNETpeeringToDC" {
  count                        = length(var.Locations)
  name                         = "peering-From-${element(azurerm_virtual_network.VNets.*.name, count.index)}-To${data.azurerm_virtual_network.UKSDCVNET.name}"
  resource_group_name          = element(azurerm_resource_group.ResourceGroup.*.name, count.index)
  virtual_network_name         = element(azurerm_virtual_network.VNets.*.name, count.index)
  remote_virtual_network_id    = data.azurerm_virtual_network.UKSDCVNET.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  depends_on                   = [azurerm_subnet.Subnets]

  # `allow_gateway_transit` must be set to false for vnet Global Peering
  allow_gateway_transit = false
}

# VNET Peering From Domain Controller VNET VNET-UKS-Main to the newly created VNETS
resource "azurerm_virtual_network_peering" "VNETpeeringFromDC" {
  count                        = length(var.Locations)
  name                         = "peering-From-${data.azurerm_virtual_network.UKSDCVNET.name}-To${element(azurerm_virtual_network.VNets.*.name, count.index)}"
  resource_group_name          = data.azurerm_resource_group.RGDCVNET.name
  virtual_network_name         = data.azurerm_virtual_network.UKSDCVNET.name
  remote_virtual_network_id    = element(azurerm_virtual_network.VNets.*.id, 1 - count.index) # 1 - count is used, I believe as the array starts with 0. Need to confirm
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  depends_on                   = [azurerm_subnet.Subnets]

  # `allow_gateway_transit` must be set to false for vnet Global Peering
  allow_gateway_transit = false
}


# Additional References - Can be cleaned up

# resource "azurerm_virtual_network_peering" "peering" {

#   name                         = "${data.azurerm_virtual_network.vnet.name}-to-${data.azurerm_virtual_network.remote.name}"
#   resource_group_name          = "group_name"
#   virtual_network_name         = data.azurerm_virtual_network.vnet.name
#   remote_virtual_network_id    = data.azurerm_virtual_network.remote.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true

#   # `allow_gateway_transit` must be set to false for vnet Global Peering
#   allow_gateway_transit = false
# }



# ## Create Network Security Group - NE
# resource "azurerm_network_security_group" "NSG-NE" {
#   name                = "NSG-${var.prefixNE}"
#   location            = var.LocationNE
#   resource_group_name = azurerm_resource_group.ResourceGroupNE.name
#   tags                = merge(var.tagsDefault, var.tagsFinance)

#   dynamic "security_rule" {
#     iterator = rule
#     for_each = var.NetworkSecurityGroupRules
#     content {
#       name                       = rule.value.name
#       priority                   = rule.value.priority
#       direction                  = rule.value.direction
#       access                     = rule.value.access
#       protocol                   = rule.value.protocol
#       source_port_range          = rule.value.source_port_range
#       destination_port_range     = rule.value.destination_port_range
#       source_address_prefix      = rule.value.source_address_prefix
#       destination_address_prefix = rule.value.destination_address_prefix

#     }

#   }
# }

# # Associate UKS subnets to security group
# resource "azurerm_subnet_network_security_group_association" "NSGUKStoSubnets" {
#   count                     = length(var.VNetsubnetsUKS)
#   subnet_id                 = azurerm_subnet.SubnetsUKS[count.index].id
#   network_security_group_id = azurerm_network_security_group.NSG-UKS.id
# }

# # Associate NE subnets to security group
# resource "azurerm_subnet_network_security_group_association" "NSGNEtoSubnet" {
#   count                     = length(var.VNetsubnetsNE)
#   subnet_id                 = azurerm_subnet.SubnetsNE[count.index].id
#   network_security_group_id = azurerm_network_security_group.NSG-NE.id
# }




# # Create Multiple Subnets in UKS
# resource "azurerm_subnet" "SubnetsUKS" {
#   count                = length(var.VNetsubnetsUKS)
#   name                 = "Subnet-${element(var.VNetsubnetNamesUKS, count.index)}-${var.prefixUKS}"
#   resource_group_name  = azurerm_resource_group.ResourceGroupUKS.name
#   virtual_network_name = azurerm_virtual_network.VNetUKS.name
#   address_prefixes     = [var.VNetsubnetsUKS[count.index]]
#   # Service endpoints - Required when doing mySQL or Cosmos DB demo
#   service_endpoints = ["Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB", "Microsoft.ContainerRegistry", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Web"]

# }



