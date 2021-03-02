resource "azurerm_network_interface" "worker-nic" {
  name                = "kub-worker-nic-${count.index}"
  location            = data.azurerm_resource_group.kub-rg.location
  resource_group_name = data.azurerm_resource_group.kub-rg.name
  enable_ip_forwarding = true
  count = 3

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kub-sub.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.240.0.1${count.index}"
  }
}

resource "azurerm_network_interface_security_group_association" "worker-nsg-assoc" {
  count = 2
  network_interface_id      = azurerm_network_interface.worker-nic[count.index].id
  network_security_group_id = data.azurerm_network_security_group.kub-nsg.id
}

resource "azurerm_linux_virtual_machine" "worker-vm" {
  name                = "kub-worker-vm-${count.index}"
  resource_group_name = data.azurerm_resource_group.kub-rg.name
  location            = data.azurerm_resource_group.kub-rg.location
  size                = "Standard_D3_v2"
  admin_username      = "adminuser"
  count = 3
  network_interface_ids = [
    azurerm_network_interface.worker-nic[count.index].id,
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