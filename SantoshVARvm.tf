

variable "add_space"            {type = list(string)}

variable "sn_addprefix"         {type = list(string)}


variable "priipallocation"      {type = string}
variable "wvm"                  {type = string}
variable "wvmsize"              {type = string}
variable "wvmadminusr"          {type = string}
variable "wvmadminpass"         {type = string}

variable "storeagetype"         {type = string}
variable "imagepublisher"       {type = string}
variable "imageoffr"            {type = string}
variable "imagesku"             {type = string}  
variable "imagevers"            {type = string}
  




terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}


resource "azurerm_resource_group" "rg" {
  name     = "${var.wvm}-rg"
  location = "${var.wvm}-loc"
}



resource "azurerm_virtual_network" "example" {
  name                     = "${var.wvm}-vnet"
  location                 = "${var.wvm}-loc"
  resource_group_name      = "${var.wvm}-rg"
  address_space            = var.add_space
}


resource "azurerm_subnet" "sninternal" {
  name                 = "${var.wvm}-subnet"
  resource_group_name  = "${var.wvm}-rg"
  virtual_network_name = "${var.wvm}-vn"
  address_prefixes     = var.sn_addprefix
}



resource "azurerm_network_interface" "armnic" {
  name                = "${var.wvm}-nic"
  location            = "${var.wvm}-loc"
  resource_group_name = "${var.wvm}-rg"

  ip_configuration {
    name                          = "${var.wvm}-ipconfig"
    subnet_id                     = azurerm_subnet.sninternal.id
    private_ip_address_allocation = var.priipallocation
  }
}



resource "azurerm_windows_virtual_machine" "example" {
  name                = "${var.wvm}"
  resource_group_name = "${var.wvm}-rg"
  location            = "${var.wvm}-loc"
  size                = var.wvmsize
  admin_username      = var.wvmadminusr
  admin_password      = var.wvmadminpass
  network_interface_ids = [
    azurerm_network_interface.armnic.id,
  ]




  os_disk {
    caching              = "${var.wvm}-osdisk"
    storage_account_type = var.storeagetype
  }  
   
  source_image_reference {
    publisher = var.imagepublisher
    offer     = var.imageoffr
    sku       = var.imagesku
    version   = var.imagevers
  }
}
