provider "azurerm" {
    features{}
    subscription_id = "redacted"
}

data "azurerm_resource_group" "kub-rg" {
    name = "dd-kub"
}

data "azurerm_virtual_network" "kub-vnet" {
    name = "kub-vnet"
    resource_group_name = data.azurerm_resource_group.kub-rg.name
}

data "azurerm_network_security_group" "kub-nsg"{
    name = "dd-kub-nsg"
    resource_group_name = data.azurerm_resource_group.kub-rg.name
}

resource "azurerm_subnet" "kub-sub" {
    name = "kub-subnet"
    resource_group_name = data.azurerm_resource_group.kub-rg.name
    virtual_network_name = data.azurerm_virtual_network.kub-vnet.name
    address_prefixes = ["10.240.0.0/24"]
}