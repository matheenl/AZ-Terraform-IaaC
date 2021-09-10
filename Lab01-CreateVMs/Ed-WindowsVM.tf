

# Create Windows Server NICs - 
resource "azurerm_network_interface" "WinVMNics" {
  count = length(var.WindowsVMNames)
  #name                = "WinVMNIC${var.prefixUKS}-${count.index}" 
  name                = "WinVMNIC-${element(var.WindowsVMNames, count.index)}"
  location            = element(azurerm_resource_group.ResourceGroup.*.location, count.index)
  resource_group_name = element(azurerm_resource_group.ResourceGroup.*.name, count.index)

  ip_configuration {
    name      = "WinVMIPConfig-${element(var.WindowsVMNames, count.index)}"
    subnet_id = element(azurerm_subnet.Subnets.*.id, count.index)
    #subnet_id                     = azurerm_subnet.SubnetsUKS[0].id
    #private_ip_address_allocation = "Dynamic"
    private_ip_address_allocation = "Static"
    private_ip_address            = element(var.VMPrivateIPs, count.index)
    #public_ip_address_id          = element(azurerm_public_ip.WinVMPublicIPs.*.id, count.index)
  }
}

# Create Windows 10 MU NICs - 
resource "azurerm_network_interface" "Win10VMNics" {
  count = length(var.Windows10VMNames)
  #name                = "WinVMNIC${var.prefixUKS}-${count.index}" 
  name                = "Win10VMNIC-${element(var.Windows10VMNames, count.index)}"
  location            = element(azurerm_resource_group.ResourceGroup.*.location, count.index)
  resource_group_name = element(azurerm_resource_group.ResourceGroup.*.name, count.index)

  ip_configuration {
    name                          = "Win10VMIPConfig-${element(var.Windows10VMNames, count.index)}"
    subnet_id                     = element(azurerm_subnet.Subnets.*.id, count.index)
    private_ip_address_allocation = "Dynamic"
  }
}


# Create Windows Server VMs -
resource "azurerm_windows_virtual_machine" "WindowsVMs" {
  count = length(var.WindowsVMNames)
  # Used different string functions to reduce the length of VM name string (max is 15)
  #name                  = "WinVM-${lower(substr((replace(var.prefix, "-", "")), 0, 4))}${count.index}"
  name                  = "${element(var.prefix, count.index)}-${element(var.WindowsVMNames, count.index)}"
  location              = element(azurerm_resource_group.ResourceGroup.*.location, count.index)
  resource_group_name   = element(azurerm_resource_group.ResourceGroup.*.name, count.index)
  size                  = var.WindowsVMsize
  admin_username        = var.VMUsername
  admin_password        = var.VMPassword
  network_interface_ids = [element(azurerm_network_interface.WinVMNics.*.id, count.index)]
  license_type          = "Windows_Client" # to use Azure HUB -- This saves cost on licencing. For Windows 10, license type may be different. Check
  tags                  = merge(var.tagsDefault, var.tagsFinance)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # Image of VM. If you need to use W10 Multi user, then change accordingly
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-smalldisk"
    version   = "latest"
  }
}

# Create Windows Client Multi Session VMs -
resource "azurerm_windows_virtual_machine" "Windows10VMs" {
  count = length(var.Windows10VMNames)
  # Used different string functions to reduce the length of VM name string (max is 15)
  #name                  = "WinVM-${lower(substr((replace(var.prefix, "-", "")), 0, 4))}${count.index}"
  name                  = "${element(var.prefix, count.index)}-${element(var.Windows10VMNames, count.index)}"
  location              = element(azurerm_resource_group.ResourceGroup.*.location, count.index)
  resource_group_name   = element(azurerm_resource_group.ResourceGroup.*.name, count.index)
  size                  = var.WindowsVMsize
  admin_username        = var.VMUsername
  admin_password        = var.VMPassword
  network_interface_ids = [element(azurerm_network_interface.WinVMNics.*.id, count.index)]
  license_type          = "Windows_Client" # to use Azure HUB -- This saves cost on licencing. For Windows 10, license type may be different. Check
  tags                  = merge(var.tagsDefault, var.tagsFinance)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # Image of VM. If you need to use W10 Multi user, then change accordingly
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-evd"
    version   = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "WindowsVMShutdownSchedule" {
  count              = length(var.WindowsVMNames) * length(var.Windows10VMNames)
  virtual_machine_id = element(azurerm_windows_virtual_machine.WindowsVMs.*.id, count.index)
  location           = element(azurerm_resource_group.ResourceGroup.*.location, count.index)
  enabled            = true

  daily_recurrence_time = "1900"
  timezone              = "UTC"

  notification_settings {
    enabled = false
  }
}

#Domain Join (DC needs to be accessible; VNET peering needs to be established to DC's VNET)
resource "azurerm_virtual_machine_extension" "VMsDomainJoin" {
  count                = length(var.WindowsVMNames) * length(var.Windows10VMNames)
  name                 = "DomJoin-${element(var.prefix, count.index)}-${element(var.WindowsVMNames, count.index)}"
  virtual_machine_id   = element(azurerm_windows_virtual_machine.WindowsVMs.*.id, count.index)
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  # What the settings mean: https://docs.microsoft.com/en-us/windows/desktop/api/lmjoin/nf-lmjoin-netjoindomain
  settings = <<SETTINGS
    {
      "Name": "technuts.co.uk",
      "OUPath": "OU=AzureServers,DC=technuts,DC=co,DC=uk",
      "User": "technuts.co.uk\\adminnal",
      "Restart": "true",
      "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
      {
        "Password": "${var.domainjoin_password}"
        }
    PROTECTED_SETTINGS

  tags = merge(var.tagsDefault, var.tagsFinance)

  # Manual Depends on block to ensure VNET Peering got created before domain joining of machines
  depends_on = [
    azurerm_virtual_network_peering.VNETpeeringToDC,
    azurerm_virtual_network_peering.VNETpeeringFromDC
  ]
}

# Additional References

# # Create Public IPs for VMs
# resource "azurerm_public_ip" "WinVMPublicIPs" {
#   # Creating public IPs for Windows VMs
#   count               = var.WindowsVMCount
#   name                = "WinPublicIP-${var.prefix}-${count.index}"
#   resource_group_name = azurerm_resource_group.ResourceGroup.name
#   location            = var.LocationDefault
#   allocation_method   = "Static"
#   ip_version          = "IPv4"
# }

# # Create NICs - NE
# resource "azurerm_network_interface" "WinVMNicsNE" {
#   count               = length(var.WindowsVMNameNE)
#   name                = "WinVMNIC${var.prefixNE}-${count.index}"
#   location            = var.LocationNE
#   resource_group_name = azurerm_resource_group.ResourceGroupNE.name

#   ip_configuration {
#     name                          = "WinVMIPConfig${var.prefixNE}"
#     subnet_id                     = azurerm_subnet.SubnetsNE[0].id
#     private_ip_address_allocation = "Dynamic"
#     #public_ip_address_id          = element(azurerm_public_ip.WinVMPublicIPs.*.id, count.index)
#   }
# }

# # to create random password for the VM (If machine creation fails, then it does not output the password and you can't log into to troubleshoot)
# resource "random_password" "RandomPassword" {
#   length           = 12
#   special          = true
#   override_special = "_%@"
# }