## Ideally All passwords should go to KeyVault -- Need to change it
# prefix    = "TF"
prefix           = ["WE", "NE"] # Match prefix with Locations
Locations        = ["West Europe", "North Europe"]
VNetAddressSpace = ["10.50.0.0/16", "10.60.0.0/16"]
VNetSubnets      = ["10.50.1.0/24", "10.60.1.0/24"]
VNetSubnetNames  = ["Internal", "External"]

Windows10VMNames = ["W10MU01", "W10MU01"]
WindowsVMNames   = ["DDC01", "VDA01"] # If creating on multiple locations
#WindowsVMNames = ["DDC01", "VDA01", "SF01", "SF01", "VDA00", "CLT01"] # If creating on multiple locations
#VMPrivateIPs = ["10.50.1.5", "10.60.1.5"] # IF creating on multiple locations
VMPrivateIPs   = ["10.50.1.5", "10.60.1.5", "10.50.1.6", "10.60.1.6", "10.50.1.7", "10.60.1.7"] # Need to match with number of VMs creating
VNetDNSServers = ["10.1.0.4"]                                                                   # Need to use only Domain Controller IP address otherwise domain join will fail

WindowsVMsize       = "Standard_B2s"
VMUsername          = "tfadmin"      # Local admin user name
VMPassword          = "P@ssw0rd123!" # Local admin password
domainjoin_password = "P@ssw0rd123!" # Password for adminnal domain account - 


NetworkSecurityGroupRules = [
  {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "RDP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "SSL"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "HTTP"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "PING"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "ICMP"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]
tagsDefault = {
  environment  = "learning"
  owner        = "Matheen Labeeb"
  subscription = "VisualStudioMPN"
  Cost         = "VS-Free"
}
tagsFinance = {
  Cost       = "FinTeam"
  Resource   = "Internal"
  Department = "Finance"

}


# Addtional notes
# VNetAddressSpace           = ["10.50.0.0/16", "10.51.0.0/16", "10.52.0.0/16", "10.53.0.0/16"]
# VNetDNSServers             = ["8.8.8.8", "10.1.0.4", "8.8.4.4"]
# VNetSubnets                = ["10.50.1.0/24", "10.51.1.0/24", "10.52.1.0/24", "10.53.1.0/24"]
# VNetSubnetNames            = ["Server", "VDI", "Test", "MYSQL"]

# Azure Lab ones
# VNetAddressSpaceUKS = ["10.50.0.0/16", "10.51.0.0/16", "10.52.0.0/16", "10.53.0.0/16"]
# VNetDNSServersUKS   = ["10.1.0.4", "168.63.129.16", "8.8.8.8"]
# VNetSubnetsUKS      = ["10.50.1.0/24", "10.51.1.0/24", "10.52.1.0/24", "10.53.1.0/24"]
# VNetSubnetNamesUKS  = ["Infra", "VDI", "DMZ", "MYSQL"]

# VNetAddressSpaceNE = ["10.60.0.0/16", "10.61.0.0/16", "10.62.0.0/16", "10.63.0.0/16"]
# VNetDNSServersNE   = ["10.1.0.4", "168.63.129.16", "8.8.8.8"]
# VNetSubnetsNE      = ["10.60.1.0/24", "10.61.1.0/24", "10.62.1.0/24", "10.63.1.0/24"]
# VNetSubnetNamesNE  = ["Infra", "VDI", "DMZ", "MYSQL"]

# WindowsVMCountUKS          = "0"
# LinuxVMCountUKS            = "2"
# WindowsVMCountNE           = "0"
# LinuxVMCountNE             = "2"
# WindowsVMCount             = "0"
# LinuxVMCount               = "2"
# DatabaseCount              = "1"
# tagsWVD = {
#   environment = "WVD"
#   VDI         = "WVD"
# }
#VNetSubnets      = ["10.50.1.0/24", "10.60.1.0/24", "10.50.2.0/24", "10.60.2.0/24", "10.50.3.0/24", "10.60.3.0/24", ]

#VNET Peering UKS Resourceid --- Not Required
#DCVNETResourceID = "/subscriptions/4f655a0b-8149-4c26-937a-115054665869/resourceGroups/RG-UKS-Main/providers/Microsoft.Network/virtualNetworks/VNET-UKS-Main"
#DCVNETResourceID = "/subscriptions/1a5b78aa-7eb5-4f21-a55a-f736258d2dd9/resourceGroups/rg-uks-main/providers/Microsoft.Network/virtualNetworks/VNET-UKS-Main"
