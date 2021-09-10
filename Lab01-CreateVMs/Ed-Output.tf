#31 Resources to Add as of 05/01
output "ResourceGroup-Names" {
  value = azurerm_resource_group.ResourceGroup.*.name
}

# output "ResourceGroup-NameNE" {
#   value = azurerm_resource_group.ResourceGroupNE.name
# }
# output "WVDResourceGroup-Name" {value = azurerm_resource_group.WVDResourceGroup.name}

# output "StorageAccount-Name" {  value = azurerm_storage_account.StorageAccount.name}

# output "StorageContainer-Name" {  value = azurerm_storage_container.StorageContainer[*].name}

# output "DNSZone-Names" {
#   # Get all the DNS Zone names by using For each loop
#   value = [for i in var.DnsZoneNames : upper(i)]
# }

# output "NetworkSecurityGroup-ID" {
#   value = azurerm_network_security_group.NetworkSecurityGroup.id
# }

# output "CosmosDB-Endpoint" {
#   value = azurerm_cosmosdb_account.cosmosdb[*].endpoint
# }

# output "CosmosDB-ID" {
#   value = azurerm_cosmosdb_account.cosmosdb[*].id
# }

output "VNetNames" {
  value = azurerm_virtual_network.VNets.*.name
}
output "VNetAddressSpace" { value = azurerm_virtual_network.VNets.*.address_space }


# output "VNetNameNE" {
#   value = azurerm_virtual_network.VNetNE.name
# }

output "Subnets-Name" {
  value = azurerm_subnet.Subnets.*.name
}
output "Subnets-AddressPrefixes" {
  value = azurerm_subnet.Subnets.*.address_prefixes
}

output "Subnets-DNSServers" {
  value = azurerm_virtual_network.VNets.*.dns_servers
}
# output "Subnets-NE" {
#   value = azurerm_subnet.SubnetsNE[*].name
# }
output "WinVMs-Name" {
  value = azurerm_windows_virtual_machine.WindowsVMs.*.name
}

output "Win10VMs-Name" {
  value = azurerm_windows_virtual_machine.Windows10VMs.*.name
}

output "WinVMs-PrivateIPs" {
  value = azurerm_network_interface.WinVMNics.*.private_ip_addresses
}

output "Win10VMs-PrivateIPs" {
  value = azurerm_network_interface.Win10VMNics.*.private_ip_addresses
}

# output "ADC-Name" {
#   value = azurerm_linux_virtual_machine.ADCVMs.*.name
# }

# output "ADC-PrivateIPs" {
#   value = azurerm_network_interface.ADCVMNics.*.private_ip_addresses
# }
# output "WinVMs-PublicIPs" {
#   value = azurerm_public_ip.WinVMPublicIPs.*.ip_address
# }

output "VNETPeeringFromDC-ID" {
  value = azurerm_virtual_network_peering.VNETpeeringFromDC.*.id
}

output "UKSDCVNET-ID" {
  value = data.azurerm_virtual_network.UKSDCVNET.id
}

# output "VNETPeeringToDC-ID" {
#   value = azurerm_virtual_network_peering.VNETpeeringToDC.*.id
# }
# output "VNETPeeringID" {
#   value = azurerm_virtual_network_peering.VNETpeering.*.id
# }

# output "WinVMsNE-Name" {
#   value = azurerm_windows_virtual_machine.WindowsVMsNE.*.name
# }
# output "LinVMsUKS-Name" {
#   value = azurerm_linux_virtual_machine.LinuxVMs.*.name
# }
# output "WinVMs-Password" {
#   value = random_password.RandomPassword.result
# }

# output "LinVMs-PublicIPAddress" {
#   value       = azurerm_public_ip.LinVMPublicIPs[*].ip_address
#   description = "This VM is in same subnet as mysql server to check connections"
# }
# output "WinVMs-PublicIPAddress" {
#   value = azurerm_public_ip.WinVMPublicIPs[*].ip_address
# }
# output "LinuxVMScaleset-ID" {
#   value = azurerm_linux_virtual_machine_scale_set.LinVMScaleset.id
# }
# output "LinuxVMScaleset-UniqueID" {
#   value = azurerm_linux_virtual_machine_scale_set.LinVMScaleset.unique_id
# }
# output "LB-PublicIPFQDN" {
#   value = azurerm_public_ip.LBPublicIP.fqdn
# }
# output "WVD-HostPooldepthfirst-ID" {
#   value = azurerm_virtual_desktop_host_pool.HostPooldepthfirst.id
# }
# output "WVD-Workspace-ID" {
#   value = azurerm_virtual_desktop_workspace.WVDWorkspace.id
# }
# output "MySQL-FQDN" {
#   value = azurerm_mysql_server.MySQLServer.fqdn
# }






