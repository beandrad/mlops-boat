resource "azurecaf_name" "vm-azdo" {
  name          = "${var.name}-azdo"
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_linux_virtual_machine"
  random_length = var.random_length
}

resource "azurecaf_name" "vm-azdo-nic" {
  name          = "${var.name}-vm-azdo"
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_types = [
    "azurerm_public_ip",
    "azurerm_network_interface"
  ]
  random_length = var.random_length
}

resource "azurerm_public_ip" "vm-azdo" {
  name                    = azurecaf_name.vm-azdo-nic.results["azurerm_public_ip"]
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "vm-azdo" {
  name                = azurecaf_name.vm-azdo-nic.results["azurerm_network_interface"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "config"
    subnet_id                     = azurerm_subnet.net.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm-azdo.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-azdo" {
  name                  = azurecaf_name.vm-azdo.result
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.vm-azdo.id]
  size                  = "Standard_A1_v2"
  admin_username        = "isa"
  admin_password = random_password.azdo-password.result
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  
}

# resource "azurerm_windows_virtual_machine" "vm-azdo" {
#   name                = azurecaf_name.vm-azdo.result
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   size                = "Standard_A1_v2"
#   admin_username      = "isa"
#   admin_password      = "P@$$w0rd1234!"
#   network_interface_ids = [
#     azurerm_network_interface.vm-azdo.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2016-Datacenter"
#     version   = "latest"
#   }
# }

resource "azurerm_virtual_machine_extension" "update-vm" {
  name                 = "update-vm"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm-azdo.id

  settings = <<SETTINGS
    {
        "script": "${filebase64("setup-azdo-agent.sh")}"
    }
SETTINGS
}
