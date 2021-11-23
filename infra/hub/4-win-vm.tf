resource "azurecaf_name" "vm-win" {
  name          = "${var.name}"
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_windows_virtual_machine"
  random_length = var.random_length
}

resource "azurecaf_name" "vm-win-nic" {
  name          = "${var.name}-win"
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_network_interface"
  random_length = var.random_length
}

resource "azurerm_network_interface" "vm-win" {
  name                = azurecaf_name.vm-win-nic.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "config"
    subnet_id                     = azurerm_subnet.net.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm-win" {
  name                = azurecaf_name.vm-win.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_A1_v2"
  admin_username      = "isa"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.vm-win.id,
  ]

  os_disk {
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
