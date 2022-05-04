
resource "azurerm_virtual_network" "vn" {
  name                = "${var.prefix}-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sn-internal-1" {
  name                 = "${var.prefix}-internal-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "sg-allow-connection" {
    name                = "${var.prefix}-allow-connection"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name


    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = var.source-address
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Graphana"
        priority                   = 1011
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3000"
        source_address_prefix      = var.source-address
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Mongo-Express"
        priority                   = 1021
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8081"
        source_address_prefix      = var.source-address
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Prometheus"
        priority                   = 1031
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "9090"
        source_address_prefix      = var.source-address
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "mongodb-exporter-mongos"
        priority                   = 1041
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "9216"
        source_address_prefix      = var.source-address
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "mongodb-exporter-rs1"
        priority                   = 1051
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "9217"
        source_address_prefix      = var.source-address
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "mongodb-exporter-rs2"
        priority                   = 1061
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "9218"
        source_address_prefix      = var.source-address
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "mongodb-exporter-cnf"
        priority                   = 1071
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "9219"
        source_address_prefix      = var.source-address
        destination_address_prefix = "*"
    }
}