resource "azurerm_public_ip" "pipA" {
  name                    = "${var.name}pipA"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "inetA" {
  name                = "${var.name}nicA"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.name}configA"
    subnet_id                     = azurerm_subnet.net.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pipA.id
  }
}

resource "tls_private_key" "cert" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "client_cert_key" {
  filename = "key.pem"
  content  = tls_private_key.cert.private_key_pem
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.name}-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.inetA.id]
  size                  = "Standard_D4s_v3"
  admin_username        = "isa"

  admin_ssh_key {
    username   = "isa"
    public_key = tls_private_key.cert.public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-LTS"
    version   = "latest"
  }
  # storage_os_disk {
  #   name              = "disk1"
  #   caching           = "ReadWrite"
  #   create_option     = "FromImage"
  #   managed_disk_type = "Standard_LRS"
  # }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
