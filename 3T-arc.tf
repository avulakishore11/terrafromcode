



# creating VNet

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet
  address_space       = var.address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# creating list of subnets


resource "azurerm_subnet" "example" {
  count                = 3
  name                 = "subnet-${count.index +1}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.${count.index}.0/24"]
}  

# Network Security Group

resource "azurerm_network_security_group" "example" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"

  }



}

# NSG association to Subnets

resource "azurerm_subnet_network_security_group_association" "nsg1" {
  count                     = 3
  subnet_id                 = azurerm_subnet.example[count.index].id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_network_interface" "example" {
  count               = 3
  name                = "nic-${count.index +1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tstpip[count.index].id
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = 3
  name                = "vm-${count.index +1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example[count.index].id,
  ]

  os_disk {
    name                 = "osdisk-${count.index + 1}"
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