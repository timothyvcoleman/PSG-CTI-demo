terraform {
  required_provider {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "psg-rg" {
  name     = "psg-resource"
  location = "West US"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "psg-vn" {
  name                = "psg-network"
  resource_group_name = azurerm_resource_group.psg-rg.name
  location            = azurerm_resource_group.psg-rg.location
  address_space       = ["10.1.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "psg-subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.psg-rg.name
  virtual_network_name = azurerm_resource_group.psg-vn.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_network_security_group" "psg-sg" {
  name                = "psg-sg"
  location            = azurerm_resource_group.psg-rg.location
  resource_group_name = azurerm_resource_group.psg-rg.name


  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "psg-dev-rule" {
  name                        = "psg-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.psg-rg.name
  network_security_group_name = azurerm_network_security_group.psg-sg.name
}

resource "azurerm_subnet_network_security_group_association" "psg_sga" {
  subnet_id                 = azurerm_subnet.psg-subnet.id
  network_security_group_id = azurerm_network_security_group.psg-sg.id
}

resource "azurerm_public_ip" "psg-ip" {
  name                = "psg-ip"
  resource_group_name = "azurerm_resource_group.psg-rg.name"
  location            = "azurerm_resource_group.psg-rg.location"
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "psg-nit" {
  name                = "psg-nit"
  location            = azurerm_resource_group.psg-rg.location
  resource_group_name = "azurerm_resource_group.psg-rg.name"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azure_subnet.psg-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.psg-ip.id
  }

  tags = {
    environment = "dev"
  }
}