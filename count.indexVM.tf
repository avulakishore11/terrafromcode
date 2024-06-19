resource "azurerm_resource_group" "tstrg" {
    name = "tstrg"
    location = "Central US"
  
}

output "azurerm_resource_group" {
      value = "resource-gp-created"
}

#VIRTUAL NETWORK

resource "azurerm_virtual_network" "tstvnet" {
    name                = "tstvnet"
    resource_group_name = azurerm_resource_group.tstrg.name
    location            = azurerm_resource_group.tstrg.location
    address_space       = ["10.0.0.0/16"]  
}

output "azurerm_virtual_network" {
    value = "virtual-network-created"
}

#SUBNET

resource "azurerm_subnet" "tstsubnet" {
    count                = 2
    name                 = "tstsn-${count.index +1}"
    resource_group_name  = azurerm_resource_group.tstrg.name
    virtual_network_name = azurerm_virtual_network.tstvnet.name
    address_prefixes     = ["10.0.${count.index}.0/24"]
}

output "azurerm_subnet" {
    value = "subnet-created"
}

# PUBLIC IP

resource "azurerm_public_ip" "tstpip" {
    count               = 2
    name                = "tstpip-${count.index +1}"
    resource_group_name = azurerm_resource_group.tstrg.name
    location            = azurerm_resource_group.tstrg.location
    allocation_method   = "Static"
    sku                 = "Standard"
}

output "azurerm_public_ip" {
    value = "public-ip-created"
}

#NETWORK SECURITY GROUP

resource "azurerm_network_security_group" "tstvmnsg" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.tstrg.location
  resource_group_name = azurerm_resource_group.tstrg.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}  

output "azurerm_network_security_group" {
    value = "nsg-created"
}

resource "azurerm_subnet_network_security_group_association" "nsg1" {
  count                     = 2
  subnet_id                 = azurerm_subnet.tstsubnet[count.index].id
  network_security_group_id = azurerm_network_security_group.tstvmnsg.id
}

output "azurerm_network_interface_security_group_association" {
    value = "associated"
}

#windows virtual machine

resource "azurerm_network_interface" "example" {
  count               = 2
  name                = "tstnic-${count.index +1}"
  location            = azurerm_resource_group.tstrg.location
  resource_group_name = azurerm_resource_group.tstrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tstsubnet[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tstpip[count.index].id
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  count               = 2
  name                = "tstvm-${count.index +1}"
  resource_group_name = azurerm_resource_group.tstrg.name
  location            = azurerm_resource_group.tstrg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example[count.index].id,
  ]

  os_disk {
    name                 = "tstos-${count.index +1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}


