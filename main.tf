provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

resource "tls_private_key" "linux_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "linux_key" {
  filename = "linuxkey.pem"
  content  = tls_private_key.linux_key.private_key_pem
}

data "azurerm_resource_group" "rg" {
  name     = "AVL-Rares-Testing"
}


# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-we-01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Create 1st subnet
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet-01"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Create 2nd subnet
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet-02"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Create 3rd subnet
resource "azurerm_subnet" "subnet3" {
  name                 = "subnet-03"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Create 1st public IP
resource "azurerm_public_ip" "publicIP1" {
  name                = "1stPublicIP"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  depends_on = [
    data.azurerm_resource_group.rg
  ]
}

# Create 2nd public IP
resource "azurerm_public_ip" "publicIP2" {
  name                = "2ndPublicIP"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  depends_on = [
    data.azurerm_resource_group.rg
  ]
}

# Create 3rd public IP
resource "azurerm_public_ip" "publicIP3" {
  name                = "3rdPublicIP"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  depends_on = [
    data.azurerm_resource_group.rg
  ]
}


# Create 1st network interface
resource "azurerm_network_interface" "nic1" {
  name                = "nic-vm1"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicIP1.id
  }

  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_public_ip.publicIP1
  ]
}

# Create 2nd network interface
resource "azurerm_network_interface" "nic2" {
  name                = "nic-vm2"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicIP2.id
  }
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_public_ip.publicIP2
  ]
}

# Create 3rd network interface
resource "azurerm_network_interface" "nic3" {
  name                = "nic-vm3"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet3.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicIP3.id
  }
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_public_ip.publicIP3
  ]
}

# Create network security group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-01"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_https"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "port_icmp"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "association1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "association2" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "association3" {
  network_interface_id      = azurerm_network_interface.nic3.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create 1st virtual machine
resource "azurerm_linux_virtual_machine" "vm1" {
  name                            = "master-node"
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.nic1.id]
  size                            = "Standard_D2s_v3"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  os_disk {
    name                 = "OsDisk1"
    disk_size_gb         = 128
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.nic1
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.linux_key.public_key_openssh
  }

  connection {
    type        = "ssh"
    user        = "adminuser"
    private_key = tls_private_key.linux_key.private_key_pem
    host        = azurerm_public_ip.publicIP1.ip_address

  }

  provisioner "file" {
  source      = "./Ansible/initial.yml"
  destination = "/home/adminuser/initial.yml"
  }

  provisioner "file" {
    source      = "./Ansible/kube-dependecies.yml"
    destination = "/home/adminuser/kube-dependecies.yml"
  }

  provisioner "file" {
    source      = "./Ansible/hosts"
    destination = "/home/adminuser/hosts"
  }

  provisioner "file" {
    source      = "./Ansible/master.yml"
    destination = "/home/adminuser/master.yml"
  }

  provisioner "file" {
    source      = "./Ansible/workers.yml"
    destination = "/home/adminuser/workers.yml"
  }

  provisioner "file" {
    source      = "./Ansible/install.sh"
    destination = "/home/adminuser/install.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "sed -i -e 's/\r$//' install.sh",
      "sudo chmod +x /home/adminuser/install.sh",
      "sudo /home/adminuser/install.sh",
    ]
  }
}

# Create 2nd virtual machine
resource "azurerm_linux_virtual_machine" "vm2" {
  name                            = "worker-1"
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.nic2.id]
  size                            = "Standard_DS1_v2"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  os_disk {
    name                 = "OsDisk2"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_linux_virtual_machine.vm1,
    azurerm_network_interface.nic2,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.linux_key.public_key_openssh
  }

  connection {
    type        = "ssh"
    user        = "adminuser"
    private_key = tls_private_key.linux_key.private_key_pem
    host        = azurerm_public_ip.publicIP2.ip_address

  }

  provisioner "file" {
  source      = "./Ansible/initial.yml"
  destination = "/home/adminuser/initial.yml"
  }

  provisioner "file" {
    source      = "./Ansible/kube-dependecies.yml"
    destination = "/home/adminuser/kube-dependecies.yml"
  }

  provisioner "file" {
    source      = "./Ansible/hosts"
    destination = "/home/adminuser/hosts"
  }

  provisioner "file" {
    source      = "./Ansible/master.yml"
    destination = "/home/adminuser/master.yml"
  }

  provisioner "file" {
    source      = "./Ansible/workers.yml"
    destination = "/home/adminuser/workers.yml"
  }

  provisioner "file" {
    source      = "./Ansible/install.sh"
    destination = "/home/adminuser/install.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "sed -i -e 's/\r$//' install.sh",
      "sudo chmod +x /home/adminuser/install.sh",
      "sudo /home/adminuser/install.sh",
    ]
  }
}

# Create 3rd virtual machine
resource "azurerm_linux_virtual_machine" "vm3" {
  name                            = "worker-2"
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.nic3.id]
  size                            = "Standard_DS1_v2"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  os_disk {
    name                 = "OsDisk3"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_linux_virtual_machine.vm2,
    azurerm_network_interface.nic3,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.linux_key.public_key_openssh
  }

  connection {
    type        = "ssh"
    user        = "adminuser"
    private_key = tls_private_key.linux_key.private_key_pem
    host        = azurerm_public_ip.publicIP3.ip_address

  }

  provisioner "file" {
  source      = "./Ansible/initial.yml"
  destination = "/home/adminuser/initial.yml"
  }

  provisioner "file" {
    source      = "./Ansible/kube-dependecies.yml"
    destination = "/home/adminuser/kube-dependecies.yml"
  }

  provisioner "file" {
    source      = "./Ansible/hosts"
    destination = "/home/adminuser/hosts"
  }

  provisioner "file" {
    source      = "./Ansible/master.yml"
    destination = "/home/adminuser/master.yml"
  }

  provisioner "file" {
    source      = "./Ansible/workers.yml"
    destination = "/home/adminuser/workers.yml"
  }

  provisioner "file" {
    source      = "./Ansible/install.sh"
    destination = "/home/adminuser/install.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "sed -i -e 's/\r$//' install.sh",
      "sudo chmod +x /home/adminuser/install.sh",
      "sudo /home/adminuser/install.sh",
    ]
  }
}