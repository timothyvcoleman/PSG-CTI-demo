terraform {
  required_providers {
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
  location = "East US"
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
  virtual_network_name = azurerm_virtual_network.psg-vn.name
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

# inbound rule for SIP port + RTP port
  resource "azurerm_network_security_rule" "psg-voip-rules" {
  name                        = "psg-voip-rules"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_ranges      = ["5060", "10000-10010"]
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
  resource_group_name = azurerm_resource_group.psg-rg.name
  location            = azurerm_resource_group.psg-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "psg-nit" {
  name                = "psg-nit"
  location            = azurerm_resource_group.psg-rg.location
  resource_group_name = azurerm_resource_group.psg-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.psg-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.psg-ip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "psg-vm" {
  name                = "psg-vm"
  resource_group_name = azurerm_resource_group.psg-rg.name
  location            = azurerm_resource_group.psg-rg.location
  size                = "Standard_D2ds_v4"
  admin_username      = "psg"
  network_interface_ids = [
    azurerm_network_interface.psg-nit.id,
  ]

  custom_data = var.host_os == "windows" ? filebase64("windows-customdata.tpl") : filebase64("linux-customdata.tpl")

# name the SSH Key Pair "psg_azure_key"
  admin_ssh_key {
    username   = "psg"
    public_key = file("~/.ssh/psg_azure_key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", {
      hostname     = self.public_ip_address,
      user         = "admin"
      identityfile = "~/.ssh/psg_azure_key"
      }
    )

    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }

  tags = {
    environment = "dev"
  }
}