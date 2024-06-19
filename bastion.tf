



resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.3.0/26"]
}


output "subnetofbastion_created" {
    value = azurerm_subnet.AzureBastionSubnet
}    

resource "azurerm_public_ip" "bastionpip" {
  name                = "bastionpip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
output "pip_created" {
    value = azurerm_public_ip.bastionpip

}

resource "azurerm_bastion_host" "tstbbtion01" {
  name                = "tstbbtion01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "bastion_ip_configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.bastionpip.id
  }
}

## Creating windows vm ##

variable "tstbastion" {
    default = "tstbastion"
  
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.tstbastion}-sn"
  resource_group_name  = azurerm_resource_group.tstrg01.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.tstbastion}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.tstbastion}-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  # When set to "false", it means that users can authenticate using passwords when connecting to the VM via SSH#

  #If you set it to "true", password authentication would be disabled, and users would need to authenticate using SSH keys instead.
 
 os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
resource "azurerm_network_security_group" "tstnsg01" {
    name = "tstnsg01"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    
    security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = ["10.0.0.0/16"]
  }
}
output "nsg_created" {
    value = azurerm_network_security_group.tstnsg01
  
}

output "vm_created" {
    value = azurerm_virtual_machine.main
    sensitive = true
}
