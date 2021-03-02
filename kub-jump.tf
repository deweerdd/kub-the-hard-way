resource "azurerm_public_ip" "jump-ip" {
  name                = "jump-pub-ip"
  resource_group_name = data.azurerm_resource_group.kub-rg.name
  location            = data.azurerm_resource_group.kub-rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "jump-nic" {
  name                = "kub-jump-nic"
  location            = data.azurerm_resource_group.kub-rg.location
  resource_group_name = data.azurerm_resource_group.kub-rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kub-sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.jump-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "jump-nsg-assoc" {
  network_interface_id      = azurerm_network_interface.jump-nic.id
  network_security_group_id = data.azurerm_network_security_group.kub-nsg.id
}

resource "azurerm_linux_virtual_machine" "jump-vm" {
  name                = "kub-jump-vm"
  resource_group_name = data.azurerm_resource_group.kub-rg.name
  location            = data.azurerm_resource_group.kub-rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.jump-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}