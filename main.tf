provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}


data "azurerm_resource_group" "rg" {
  name     = "Rares-Testing"
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

# Create network security group for master-node
resource "azurerm_network_security_group" "nsg_master" {
  name                = "master-nsg"
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
    name                       = "k8s-api-server"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
 security_rule {
    name                       = "etcd-server-client-api"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2379-2380"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

 security_rule {
    name                       = "api-scheduler-controller"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10250-10252"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
}

# Create network security group for worker-node
resource "azurerm_network_security_group" "nsg_workers" {
  name                = "workers-nsg"
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
    name                       = "kubelet-API"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10250"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "NodePortServices"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
resource "azurerm_network_interface_security_group_association" "association1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg_master.id
}

resource "azurerm_network_interface_security_group_association" "association2" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.nsg_workers.id
}

resource "azurerm_network_interface_security_group_association" "association3" {
  network_interface_id      = azurerm_network_interface.nic3.id
  network_security_group_id = azurerm_network_security_group.nsg_workers.id
}


# Create 1st virtual machine
resource "azurerm_linux_virtual_machine" "vm1" {
  name                            = "master-node"
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.nic1.id]
  size                            = "Standard_D2s_v3"
  admin_username                  = "adminuser"
  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
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
}

# Create 2nd virtual machine
resource "azurerm_linux_virtual_machine" "vm2" {
  name                            = "worker-node1"
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.nic2.id]
  size                            = "Standard_D2s_v3"
  admin_username                  = "adminuser"
  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  disable_password_authentication = true

  os_disk {
    name                 = "OsDisk2"
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
 }

# Create 3rd virtual machine
resource "azurerm_linux_virtual_machine" "vm3" {
  name                            = "worker-node2"
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.nic3.id]
  size                            = "Standard_D2s_v3"
  admin_username                  = "adminuser"
  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  disable_password_authentication = true

  os_disk {
    name                 = "OsDisk3"
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
 }
 
