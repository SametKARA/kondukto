# demo instance
resource "azurerm_virtual_machine" "vm-instance" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.ni-instance.id]
  vm_size               = "Standard_A1_v2"

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.prefix
    admin_username = var.vmuser
    #admin_password = "..."
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("${var.vmuser}_rsa.pub")
      path     = "/home/${var.vmuser}/.ssh/authorized_keys"
    }
  }
}

# resource "time_sleep" "wait" {
#   depends_on = [azurerm_virtual_machine.vm-instance, azurerm_public_ip.pi-instance]
#   # public IP alabilmesi için
#   create_duration = "60s"
# }

resource "null_resource" "execute" {
  connection {
    type        = "ssh"
    user        = "${var.vmuser}"
    password    = ""
    private_key = file("${var.vmuser}_rsa")
    host        = data.azurerm_public_ip.public_ip_address.ip_address
  }

  provisioner "file" {
    source      = "provision/"
    destination = "/home/${var.vmuser}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.vmuser}/commands.sh",
      "chmod +x /home/${var.vmuser}/mongoscripts/init-shard.sh",
      "chmod +x /home/${var.vmuser}/mongoscripts/setup.sh",
      "sudo /home/${var.vmuser}/commands.sh",
    ]
  }
  depends_on = [azurerm_virtual_machine.vm-instance, azurerm_public_ip.pi-instance]
  #depends_on = [time_sleep.wait]
}

resource "azurerm_network_interface" "ni-instance" {
  name                      = "${var.prefix}-network-interface"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "instance1"
    subnet_id                     = azurerm_subnet.sn-internal-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pi-instance.id
  }
}

resource "azurerm_network_interface_security_group_association" "allow-connection" {
  network_interface_id      = azurerm_network_interface.ni-instance.id
  network_security_group_id = azurerm_network_security_group.sg-allow-connection.id
}

resource "azurerm_public_ip" "pi-instance" {
    name                         = "${var.prefix}-public-ip"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"
}

data "azurerm_public_ip" "public_ip_address" {
  name                = "${azurerm_public_ip.pi-instance.name}"
  resource_group_name = "${azurerm_virtual_machine.vm-instance.resource_group_name}"
}

output "public_ip" {
  description = "public IP address of ubuntu server"
  value       = data.azurerm_public_ip.public_ip_address.ip_address
}

output "Grafana_Dashboards_link" {
  description = "to access grafana dashboards"
  value       = "http://${data.azurerm_public_ip.public_ip_address.ip_address}:3000/dashboards"
}


output "Grafana_MongoDB_Dashboard_link" {
  description = "to access grafana mongodb dashboard"
  value       = "http://${data.azurerm_public_ip.public_ip_address.ip_address}:3000/d/AyWQt9jWk/mongodb_dashboard?orgId=1&refresh=1m"
}

output "Mongo-Express_link" {
  description = "to access Mongo Express"
  value       = "http://${data.azurerm_public_ip.public_ip_address.ip_address}:8081"
}

output "Prometheus_link" {
  description = "to access prometheus"
  value       = "http://${data.azurerm_public_ip.public_ip_address.ip_address}:9090/targets"
}

output "Mongo_Exporter_Mongos_link" {
  description = "to access Mongo Exporter"
  value       = "http://${data.azurerm_public_ip.public_ip_address.ip_address}:9216/metrics"
}

output "Mongo_Exporter_RS1_link" {
  description = "to access Mongo Exporter"
  value       = "http://${data.azurerm_public_ip.public_ip_address.ip_address}:9217/metrics"
}

output "Mongo_Exporter_RS2_link" {
  description = "to access Mongo Exporter"
  value       = "http://${data.azurerm_public_ip.public_ip_address.ip_address}:9218/metrics"
}

output "Mongo_Exporter_CNF_link" {
  description = "to access Mongo Exporter"
  value       = "http://${data.azurerm_public_ip.public_ip_address.ip_address}:9219/metrics"
}

output "ssh_connection_command" {
  description = "to access ubuntu server"
  value       = "ssh -i ${var.vmuser}_rsa ${var.vmuser}@${data.azurerm_public_ip.public_ip_address.ip_address}"
}
