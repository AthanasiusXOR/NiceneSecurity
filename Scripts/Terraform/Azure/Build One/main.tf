####################################################################################################
# Script Name: main.tf
# Description: This is the main.tf (TerraForm) script - this walks through Virtual Machine Set-up. 
# Author: AthanasiusXOR
# Copyright (C) 2025 AthanasiusXOR (Red Team Security Engineer)
#
# Version: 1.0.0
# Last Updated: 2025-06-01
# Version History
#   1.0.0   2025-06-01  Initial version
#
#
####################################################################################################
#
# Specify required Terraform version and Azure Provider
terraform {
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = "~>3.0" # Adjust this to match the specific version of Hashicorp needs. 
      }
    }
    required_version = ">= 1.9" # Require TerraForm Version is 1.9 and above. This can be changed if needed.
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources =  false # This is a deletion protection. But do not trust it. The "terraform delete/destroy" command will delete ALL in the resource_group_name.
    }
  }
}

# Create Resource Groups if they are not already created. 
# It is important that the Resource Group is identified. In the variables.tf the resource_group is identified. However, here you must also define in the resource section. 
resource "azurerm_resource_group" "main" {
  name = var.resource_group_name
  location = var.location
}

# Define the Kali0 Virtual Machine
# Kali0 is used as a throwaway machine. See the network.tf for the IP scheme for this particular VM. 
# Should be away from "all" other infrastructor.
resource "azurerm_linux_virtual_machine" "kali0_vm" {
  name = "Kali0"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.username
  network_interface_ids = [azurerm_network_interface.kali0_nic.id]

  plan {
    name = "kali-2024-2"
    product = "kali"
    publisher = "kali-linux"
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type =  "Premium_LRS"
    disk_size_gb = 256
  }

  admin_ssh_key {
    username = var.username
    public_key = file(var.ssh_public_keys[0]) # Path to SSH Public Key. All users that are going to be using this machine will need to create SSH Key Pairs in Azure.
  }

  source_image_reference {
    publisher = "kali-linux"
    offer = "kali"
    sku = "kali-2024-2"
    version = "latest"
  }
  provisioner "file" {
    source = "./kalisetup.sh"
    destination = "/home/<username>/kalisetup.sh" # This will need to be updated based on username configuration
  }
  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/<username>/kalisetup.sh", # This will need to be updated based on username configuration
      "sudo rm /home/<username>/kalisetup.sh", # This will need to be updated based on username configuration
      "sudo systemctl start xrdp",
      "sudo systemctl start ssh",
      "exit 0"
    ]
  }
    connection {
    type = "ssh"
    host = azurerm_public_ip.kali0_public_ip.ip_address
    user = "<username>"
    private_key = file("Path/to/Private/Key")
  }
}

# Define the Kali1 Virtual Machine, this is for the Operator.
resource "azurerm_linux_virtual_machine" "kali1_vm" {
  name                = "Kali1"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.username
  network_interface_ids = [azurerm_network_interface.kali1_nic.id]
  plan {
    name = "kali-2024-2"
    product = "kali"
    publisher = "kali-linux"
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type =  "Premium_LRS"
    disk_size_gb = 256
  }

  admin_ssh_key {
    username = var.username
    public_key = file(var.ssh_public_keys[0]) # Path to SSH Public Key. All users that are going to be using this machine will need to create SSH Key Pairs in Azure.
  }

  source_image_reference {
    publisher = "kali-linux"
    offer = "kali"
    sku = "kali-2024-2"
    version = "latest"
  }
  provisioner "file" {
    source = "./kalisetup.sh"
    destination = "/home/<username>/kalisetup.sh" # This will need to be updated based on username configuration
  }
  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/<username>/kalisetup.sh", # This will need to be updated based on username configuration
      "sudo rm /home/<username>/kalisetup.sh", # This will need to be updated based on username configuration
      "sudo systemctl start xrdp",
      "sudo systemctl start ssh",
      "exit 0"
    ]
  }
    connection {
     type = "ssh"
     host = azurerm_public_ip.kali1_public_ip.ip_address
     user = "<username>"
     private_key = file("Path/to/Private/Key")
  }
}

# Define the Kali2 Virtual Machine, this is for the Operator.
resource "azurerm_linux_virtual_machine" "kali2_vm" {
  name                = "Kali2"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.username
  network_interface_ids = [azurerm_network_interface.kali2_nic.id]

  plan {
    name = "kali-2024-2"
    product = "kali"
    publisher = "kali-linux"
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type =  "Premium_LRS"
    disk_size_gb = 256
  }

  admin_ssh_key {
    username = var.username
    public_key = file(var.ssh_public_keys[0]) # Path to SSH Public Key. All users that are going to be using this machine will need to create SSH Key Pairs in Azure.
  }

  source_image_reference {
    publisher = "kali-linux"
    offer = "kali"
    sku = "kali-2024-2"
    version = "latest"
  }
  provisioner "file" {
    source = "./kalisetup.sh"
    destination = "/home/<username>/kalisetup.sh" # This will need to be updated based on username configuration
  }
  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/<username>/kalisetup.sh", # This will need to be updated based on username configuration
      "sudo rm /home/<username>/kalisetup.sh", # This will need to be updated based on username configuration
      "sudo systemctl start xrdp",
     "sudo systemctl start ssh",
      "exit 0"
    ]
  } 
  connection {
    type = "ssh"
    host = azurerm_public_ip.kali2_public_ip.ip_address
    user = "azureuser"
    private_key = file("Path/to/Private/Key")
  }
}

# Define the Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "windows0_vm" {
  name                = "Windows_VM"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.username
  network_interface_ids = [azurerm_network_interface.windows_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_password = var.windows_admin_password # Reminder to update the secure password in the varaibles.tf. 

source_image_reference {
  publisher = "MicrosoftWindowsDesktop"
  offer = "windows-11"
  sku = "win11-22h2-pro"
  version = "latest"
}

  connection {
    type = "winrm"
    host = azurerm_public_ip.windows_public_ip.ip_address
    user = var.username
    password = var.windows_admin_password
    https = false
    insecure = true
  }
}

# Define the GoPhish Virtual Machine
resource "azurerm_linux_virtual_machine" "gophish_vm" {
  name                = "GoPhish"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.username
  network_interface_ids = [azurerm_network_interface.gophish_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username = var.username
    public_key = file(var.ssh_public_keys[0]) # Path to SSH Public Key. All users that are going to be using this machine will need to create SSH Key Pairs in Azure.
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18_04-lts-gen2"
    version = "latest"
  }
}

# Define the Redirector 1 Virtual Machine
resource "azurerm_linux_virtual_machine" "redirector1_vm" {
  name                = "Redirector1"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.username
  network_interface_ids = [azurerm_network_interface.redirector1_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username = var.username
    public_key = file(var.ssh_public_keys[0]) # Path to SSH Public Key. All users that are going to be using this machine will need to create SSH Key Pairs in Azure.
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18_04-lts-gen2"
    version = "latest"
  }
  provisioner "file" {
    source = "./smb.sh"
    destination = "/home/azureuser/smb.sh" # This will need to be updated based on username configuration
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/<username>/smb.sh", # This will need to be updated based on username configuration
      "sudo bash /home/<username>/smb.sh", # This will need to be updated based on username configuration
      "exit 0"
     ]
  }
  connection {
    type = "ssh"
    host = azurerm_public_ip.redirector1_public_ip.ip_address
    user = "<username>"
    private_key = file("Path/to/Private/Key")
  }
}

# Define the Redirector 2 Virtual Machine
resource "azurerm_linux_virtual_machine" "redirector2_vm" {
  name                = "Redirector2"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.username
  network_interface_ids = [azurerm_network_interface.redirector2_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username = var.username
    public_key = file(var.ssh_public_keys[0]) # Path to SSH Public Key. All users that are going to be using this machine will need to create SSH Key Pairs in Azure.
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18_04-lts-gen2"
    version = "latest"
  }
  provisioner "file" {
    source = "./smb.sh"
    destination = "/home/<username>/smb.sh" # This will need to be updated based on username configuration
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/<username>/smb.sh", # This will need to be updated based on username configuration
      "sudo bash /home/<username>/smb.sh", # This will need to be updated based on username configuration
      "exit 0"
     ]
    }
  connection {
    type = "ssh"
    host = azurerm_public_ip.redirector2_public_ip.ip_address
    user = "azureuser"
    private_key = file("Path/to/Private/Key")
  }
}

# Define the Command and Control (C2) Virtual Machine
resource "azurerm_linux_virtual_machine" "teamserver_vm" {
  name                = "TeamServer"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.username
  network_interface_ids = [azurerm_network_interface.teamserver_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username = var.username
    public_key = file(var.ssh_public_keys[0]) # Path to SSH Public Key. All users that are going to be using this machine will need to create SSH Key Pairs in Azure.
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18_04-lts-gen2"
    version = "latest"
  }
  provisioner "file" {
    source = "./teamserver.sh"
    destination = "/home/<username>/teamserver.sh" # This will need to be updated based on username configuration
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/<username>/teamserver.sh", # This will need to be updated based on username configuration
      "sudo bash /home/<username>/teamserver.sh", # This will need to be updated based on username configuration
      "exit 0"
     ]
  }
  connection {
    type = "ssh"
    host = azurerm_public_ip.teamserver_public_ip.ip_address
    user = "<username>"
    private_key = file("Path/to/Private/Key")
  }
}

# Define the Evilingx (GoPhish Proxy) Virtual Machine
resource "azurerm_linux_virtual_machine" "evilingx_vm" {
  name                = "Evilingx"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.username
  network_interface_ids = [azurerm_network_interface.Evilingx_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username = var.username
    public_key = file(var.ssh_public_keys[0]) # Path to SSH Public Key. All users that are going to be using this machine will need to create SSH Key Pairs in Azure.
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18_04-lts-gen2"
    version = "latest"
  }
}
