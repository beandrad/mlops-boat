resource "azurecaf_name" "bastion" {
  name          = var.name
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_bastion_host"
  random_length = var.random_length
}

resource "azurecaf_name" "bastion-ip" {
  name          = "${var.name}-bastion"
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_public_ip"
  random_length = var.random_length
}

resource "azurerm_subnet" "bastion-subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.net.name
  address_prefixes     = var.bastion_subnet_address_space
}


resource "azurerm_public_ip" "bastion" {
  name                = azurecaf_name.bastion-ip.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = azurecaf_name.bastion.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-subnet.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
