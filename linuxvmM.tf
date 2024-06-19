#variables
variable "rgname" { 
    type = string
}    
variable "location" { 
    type = string
}    
variable "vn" {
    type = string 
}
variable "subent" {
    type = string 
}
variable "network_interface" {
    type = string 
}
variable "windows_virtual_machine" {
    type = string 
}
variable "address_space" {
    type = list(string) 
}
variable "address_prefixes" {
    type = list(string) 
}
variable "private_ip_address_allocation" {
    type = string 
}
variable "admin_username" {
    type = string 
}
variable "admin_password" {
    type = string 
}
variable "ip_configuration" { 
    type = string
}
variable "size" { 
    type = string
}
variable "osdisk_name" { 
    type = string
}
variable "managed_disk_name" { 
    type = string
}
variable "ddsize" { 
    type = number
}
variable "managed_disk_name-03" { 
    type = string
}
variable "ddsize03" { 
    type = number
}


    



##configuring a vm01##

module "wvm01" {
 source                        = "./module/vm-tmplate"
 rgname                        = "rgforVM01"
 location                      = "Central US"
 vn                            = "tstvn01"
 subent                        = "tstsubnet01"
 network_interface             = "tstvm01nic"
 windows_virtual_machine       = "tstwvm01"
 address_space                 = ["10.0.0.0/16"]
 address_prefixes              = ["10.0.1.0/24"]
 private_ip_address_allocation = "Dynamic"
 admin_username                = "azureuser"
 admin_password                = "Kishore@12345"
 ip_configuration              = "tstvmnicipconfig"
 osdisk_name                   = "tstosdisk"
size                           = "Standard_F2"
managed_disk_name              = "tst_managed_disk"
ddsize                         =  13
ddsize03                       = 16
managed_disk_name-03           = "adding-additional-disk03"
}




resource "azurerm_resource_group" "rgname" {
  name     = var.rgname
  location = var.location
}

resource "azurerm_virtual_network" "vn" {
  name                = var.vn
  address_space       = var.address_space
  location            = azurerm_resource_group.rgname.location
  resource_group_name = azurerm_resource_group.rgname.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subent
  resource_group_name  = azurerm_resource_group.rgname.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = var.address_prefixes
}

resource "azurerm_network_interface" "nic" {
  name                = var.network_interface
  location            = azurerm_resource_group.rgname.location
  resource_group_name = azurerm_resource_group.rgname.name

  ip_configuration {
    name                          = var.ip_configuration
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = var.private_ip_address_allocation
  }
}

resource "azurerm_windows_virtual_machine" "wvm01" {
  name                = var.windows_virtual_machine
  resource_group_name = azurerm_resource_group.rgname.name
  location            = azurerm_resource_group.rgname.location
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    name                 = var.osdisk_name
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

resource "azurerm_managed_disk" "managed_disk_name" {
  name                 = var.managed_disk_name
  location             = azurerm_resource_group.rgname.location
  resource_group_name  = azurerm_resource_group.rgname.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.ddsize
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.managed_disk_name.id
  virtual_machine_id = azurerm_windows_virtual_machine.wvm01.id
  lun                = 2
  caching            = "ReadWrite"
}
##adding additional data disks to vm##
resource "azurerm_managed_disk" "managed_disk_name-03" {
  name                 = var.managed_disk_name-03
  location             = azurerm_resource_group.rgname.location
  resource_group_name  = azurerm_resource_group.rgname.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.ddsize03
}
resource "azurerm_virtual_machine_data_disk_attachment" "additional-dd03" {
  managed_disk_id    = azurerm_managed_disk.managed_disk_name-03.id
  virtual_machine_id = azurerm_windows_virtual_machine.wvm01.id
  lun                = 3
  caching            = "ReadWrite"
}