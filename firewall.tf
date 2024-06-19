
# AFW  DEDICATED SUBNET
resource "azurerm_subnet" "fw-sn" {
  name = "AzureFirewallSubnet"
  resource_group_name = azurerm_resource_group.example.name
  address_prefixes = ["10.0.2.0/26"]
  virtual_network_name = azurerm_virtual_network.example.name
}


# AFW PUBLIC IP ADDRESS
resource "azurerm_public_ip" "example-firewall" {
    name = "exmple-nic"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "Static"
    sku = "Standard"
  
}

resource "azurerm_firewall" "example" {
  name                = "testfirewall"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.fw-sn.id
    public_ip_address_id = azurerm_public_ip.example-firewall.id
  }
}

resource "azurerm_firewall_network_rule_collection" "example" {
  name                = "testcollection"
  azure_firewall_name = azurerm_firewall.example.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "testrule"

    source_addresses = [
      "*",
    ]

    
    destination_ports = [
      "22",
    ]

    destination_addresses = [
      "10.0.1.4",
    ]

    protocols = [
      "TCP",
      "UDP",
    ]
  }
}  