###################################################################################################
# Script Name: network.tf
# Description: This is the network.tf (TerraForm) script - this walks through the Network Settings, to include Network Security Groups (NSG) and Subnets.
# There are multiple Network Security Groups, as each set of machines will have (or must have) different requiremetns for connectiosn between each other in the network.
# Author: Athansius of Alexandria
# Copyright (C) 2025 AthanasiusXOR (Red Team Security Engineer)
#
# Version: 1.0.0
# Last Updated: 2025-06-01
# Version History
#   1.0.0   2025-06-01  Initial version
#
#
####################################################################################################

# Define the default Virtual Network (VNet)
# Make sure to update the name of the default vnet to something that is operational sepcific.
resource "azurerm_virtual_network" "default_vnet" {
  name                = "default-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]
}

# Define a subnet. In this case, we are using 10.0.1.0/16, shiooter preference on this. Change as you see fit.
# Make sure to update the name of the default subnet vnet to something that is operational sepcific.
resource "azurerm_subnet" "default_subnet" {
  name                 = "default-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define the Isolated subnet, make sure that this subnet is different than the subnet listed above. This is to ensure tha our Kali0 is on a separate and segmented network for "scanning."
# Make sure to update the name of the default isoaltion subnet vnet to something that is operational sepcific.
resource "azurerm_subnet" "isolated_subnet" {
  name = "isolated_subnet"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default_vnet.name
  address_prefixes = ["10.0.10.0/24"]
}

# NETWORK SECURITY GROUPS
# 01. Network Security Group for GoPhish Server. 
resource "azurerm_network_security_group" "gophish_nsg" { 
  name = "gophish-nsg" 
  location = var.location 
  resource_group_name = var.resource_group_name 
# Inbound Rules
# Allow HTTP (Port 80) 
  security_rule { 
    name = "Allow_Inbound_HTTP" 
    priority = 100 
    direction = "Inbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "80" 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  } 
# Allow HTTPS (Port 443) 
  security_rule { 
    name = "Allow_Inbound_HTTPS" 
    priority = 101 
    direction = "Inbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "443" 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  } 
# Allow SMTP (Port 587) 
  security_rule { 
    name = "Allow_Inbound_SSMTP" 
    priority = 102 
    direction = "Inbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "587" # This can also be 465, for SSL. 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  } 
# Allow GoPhish API (Port 3333) for communication with Evilginx 
  security_rule { 
    name = "Allow_Inbound_GoPhishAPI" 
    priority = 103
    direction = "Inbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "3333" 
    source_address_prefix = azurerm_network_interface.Evilingx_nic.private_ip_address # Restrict to Evilginx's IP 
    destination_address_prefix = "*" 
  } 
# Allow SSH (Port 22) 
  security_rule { 
    name = "Allow_Inbound_SSH" 
    priority = 104
    direction = "Inbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "22" 
    source_address_prefix = "<IP Address>" # This need to be a public IP address of the user host.
    destination_address_prefix = "*" 
  } 
# Outbound Rules
# Allow Secure SMTP (Port 587) 
  security_rule { 
    name = "Allow_Outbound_SSMTP" 
    priority = 100
    direction = "Outbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "587" 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  } 
# Allow DNS (Port 53) 
  security_rule { 
    name = "Allow_Outbound_DNS" 
    priority = 101 
    direction = "Outbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "53" 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  }
# Allow HTTP (Port 80) 
  security_rule { 
    name = "Allow_Outbound_HTTP" 
    priority = 102 
    direction = "Outbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "80" 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  }  
# Allow HTTPS (Port 443) 
  security_rule { 
    name = "Allow_Outbound_HTTPS" 
    priority = 103 
    direction = "Outbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "443" 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  } 
} 

# 02. Network Security Group for Evilingx Server
resource "azurerm_network_security_group" "evilingx_nsg" { 
  name = "evilingx-nsg" 
  location = var.location 
  resource_group_name = var.resource_group_name 
# Inbound Rules
# Allow HTTP (Port 80) 
  security_rule { 
    name = "Allow_Inbound_HTTP" 
    priority = 100 
    direction = "Inbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "80" 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  } 
  # Allow HTTPS (Port 443) 
  security_rule { 
    name = "Allow_Inbound_HTTPS" 
    priority = 101
    direction = "Inbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "443" 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  } 
  # Allow DNS (Port 53) 
  security_rule { 
    name = "Allow_Inbound_DNS" 
    priority = 102 
    direction = "Inbound" 
    access = "Allow" 
    protocol = "Udp" 
    source_port_range = "*" 
    destination_port_range = "53" 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  }
    # Allow SSH (Port 22) 
  security_rule { 
    name = "Allow_SSH" 
    priority = 103
    direction = "Inbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "22" 
    source_address_prefix = "<IP Address>" # Need to insert Public IP Address.
    destination_address_prefix = "*" 
  } 
  # Outbound Rules
  # Allow DNS (Port 53) 
  security_rule { 
    name = "Allow_Outbound_DNS" 
    priority = 100 
    direction = "Outbound" 
    access = "Allow" 
    protocol = "Udp" 
    source_port_range = "*" 
    destination_port_range = "53" 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  }
  # Allow HTTP (Port 80) 
  security_rule { 
    name = "Allow_Outbound_HTTP" 
    priority = 101 
    direction = "Outbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "80" 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  } 
  # Allow HTTPS (Port 443) 
  security_rule { 
    name = "Allow_Outbound_HTTPS" 
    priority = 102 
    direction = "Outbound" 
    access = "Allow" 
    protocol = "Tcp" 
    source_port_range = "*" 
    destination_port_range = "443" 
    source_address_prefix = "*" 
    destination_address_prefix = "*" 
  } 
} 

# 03. Network Secuirty Group for Kali0, Kali1, and Kali2.
resource "azurerm_network_security_group" "kali_nsg" {
  name = "kali_nsg"
  location = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]
# Inbound Rules
# Allow SSH (Port 22)
  security_rule {
    name = "Allow_Inbound_SSH"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "<IP Address>" #Need to insert Public IP Address
    destination_address_prefix = "*"
  }
 # Allow RDP (Port 3389) 
  security_rule {
    name = "Allow_Inbound_RDP"
    priority = 101
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
   source_address_prefix = "<IP Address>" # Need to insert Public IP Address of the Operator(s) Will need multiple for multiple Operators.
    source_port_range = "*"
    destination_port_range = "*"
    destination_address_prefix = "*"
  }
# Allow Cobaltstrike (Port 50050)
  security_rule {
    name = "Allow_Inbound_CobaltStrike"
    priority = 106
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_address_prefix = "10.0.1.0/24" # This can be changed to just the Private IP Address of the Team Server.
    source_port_range ="*"
    destination_port_range = "50050"
    destination_address_prefix = "*"
  }
}

# 04. Network Security for the TeamServer (Cobaltstrike)

resource "azurerm_network_security_group" "teamserver_nsg" {
  name = "teamserver-nsg"
  location = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]
# Inbound Rules
# Allow SSH (Port 22)
  security_rule {
    name = "Allow_Inbound_SSH"
    priority = 104
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_address_prefix = "10.0.1.0/24" # This is the Subnet IP CIDR that you provided in Line 30.
    source_port_range= "*"
    destination_port_range = "22"
    destination_address_prefix = "*"
  }
}

# 05. Network Security for the Redirectors.
resource "azurerm_network_security_group" "redirector_nsg" {
  name = "redirector-nsg"
  location = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]
# Inbounrd Rules
  # Allow SSH (Port 22)
    security_rule {
    name = "Allow_Inbound_SSH"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "10.0.1.0/24" # This is the subetnet provided in Line 30. Redirector cannot accessed publically. 
    destination_address_prefix = "*"
 }
}
### You will need to inject all of the Azure FrontDoor IP Addresses. See PowerShell Script.

# 06. Network Security for Win0. 
resource "azurerm_network_security_group" "windows_nsg" {
  name = "windows-nsg"
  location = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]
# Inbound Rules
# Allow RDP (Port 3389)
  security_rule {
    name = "Allow_Inbound_RDP"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_address_prefix = "*" # Need to identify the Private IP for this. 
    source_port_range = "*"
    destination_port_range = "3389"
    destination_address_prefix = "*"
  }
}

# Define the Public IPs for the Virtual Machines
# Define the Public IP for GoPhish
resource "azurerm_public_ip" "gophish_public_ip" {
  name  = "gophish-public-ip"
  location = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Dynamic"
  depends_on = [azurerm_resource_group.main]
}

# Define the Public IP for Team Server
# This is here if needed. It is mostly likely that we will keep this hidden and private.
# resource "azurerm_public_ip" "teamserver_public_ip" {
#  name  = "teamserver-public-ip"
#  location = var.location
#  resource_group_name = var.resource_group_name
#  allocation_method = "Dynamic"
#  depends_on = [azurerm_resource_group.main]
#}

# Define the Public IP for Windows VM
resource "azurerm_public_ip" "windows_public_ip" {
  name  = "windows-public-ip"
  location = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  depends_on = [azurerm_resource_group.main]
}

# Define the Public IP for Kali0 VM
resource "azurerm_public_ip" "kali0_public_ip" {
  name  = "kali0-public-ip"
  location = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  depends_on = [azurerm_resource_group.main]
}

# Define the Public IP for Kali1 VM
resource "azurerm_public_ip" "kali1_public_ip" {
  name  = "kali1-public-ip"
  location = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  depends_on = [azurerm_resource_group.main]
}

# Define the Public IP for Kali2 VM
resource "azurerm_public_ip" "kali2_public_ip" {
  name  = "kali2-public-ip"
  location = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  depends_on = [azurerm_resource_group.main]
}

# Define the Public IP for Redirector1
resource "azurerm_public_ip" "redirector1_public_ip" {
  name  = "redirector1-public-ip"
  location = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  depends_on = [azurerm_resource_group.main]
}

# Define the Public IP for Redirector2
resource "azurerm_public_ip" "redirector2_public_ip" {
  name  = "redirector2-public-ip"
  location = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  depends_on = [azurerm_resource_group.main]
}

# Define the Public IP for Evilingx
resource "azurerm_public_ip" "Evilingx_public_ip" {
  name  = "Evilingx-public-ip"
  location = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  depends_on = [azurerm_resource_group.main]
}

# Define the Public IP for TeamServer
resource "azurerm_public_ip" "teamserver_public_ip" {
  name  = "teamserver-public-ip"
  location = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Static"
  depends_on = [azurerm_resource_group.main]
}

# Define the Network Interfaces (NICs)
#Define Network Interface for Phishing Infrastructure. 
resource "azurerm_network_interface" "gophish_nic" {
  name                = "gophish-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]

  ip_configuration {
    name = "gophish-ip-config"
    subnet_id = azurerm_subnet.default_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.gophish_public_ip.id
  }
}
resource "azurerm_network_interface_security_group_association" "gophish_nic_nsg" {
  network_interface_id = azurerm_network_interface.gophish_nic.id
  network_security_group_id = azurerm_network_security_group.gophish_nsg.id
}

# Define Network Interface for Windows Infrastructure.
resource "azurerm_network_interface" "windows_nic" {
  name                = "windows-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]

  ip_configuration {
    name = "windows-ip-config"
    subnet_id = azurerm_subnet.default_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.windows_public_ip.id
  }
}
resource "azurerm_network_interface_security_group_association" "windows_nic_nsg" {
  network_interface_id = azurerm_network_interface.windows_nic.id
  network_security_group_id = azurerm_network_security_group.windows_nsg.id
}

# Define Network Interface for Kali0
resource "azurerm_network_interface" "kali0_nic" {
  name                = "kali0-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]

  ip_configuration {
    name = "kali0-ip-config"
    subnet_id = azurerm_subnet.isolated_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.kali0_public_ip.id
  }
}
resource "azurerm_network_interface_security_group_association" "kali0_nic_nsg" {
  network_interface_id = azurerm_network_interface.kali0_nic.id # The network interface ID for Kali1
  network_security_group_id = azurerm_network_security_group.kali_nsg.id # The network security group ID for Kali.
}

# Define Network Interface for Kali1
resource "azurerm_network_interface" "kali1_nic" {
  name                = "kali1-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]

  ip_configuration {
    name = "kali1-ip-config"
    subnet_id = azurerm_subnet.default_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.kali1_public_ip.id
  }
}
resource "azurerm_network_interface_security_group_association" "kali1_nic_nsg" {
  network_interface_id = azurerm_network_interface.kali1_nic.id # The network interface ID for Kali1
  network_security_group_id = azurerm_network_security_group.kali_nsg.id # The network security group ID for Kali.
}

# Define Network Interface for Kali2
resource "azurerm_network_interface" "kali2_nic" {
  name                = "kali2-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]

  ip_configuration {
    name = "kali2-ip-config"
    subnet_id = azurerm_subnet.default_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.kali2_public_ip.id
  }
}
resource "azurerm_network_interface_security_group_association" "kali2_nic_nsg" {
  network_interface_id = azurerm_network_interface.kali2_nic.id # The network interface ID for Kali1
  network_security_group_id = azurerm_network_security_group.kali_nsg.id # The network security group ID for Kali.
}

# Define Network Interface for Redirector1
resource "azurerm_network_interface" "redirector1_nic" {
  name                = "redirector1-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]

  ip_configuration {
    name = "redirector1-ip-config"
    subnet_id = azurerm_subnet.default_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.redirector1_public_ip.id
  }
}
resource "azurerm_network_interface_security_group_association" "redirector1_nic_ngs" {
  network_interface_id = azurerm_network_interface.redirector1_nic.id
  network_security_group_id = azurerm_network_security_group.redirector_nsg.id
}

# Define Network Interface for Redirector2
resource "azurerm_network_interface" "redirector2_nic" {
  name                = "redirector2-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]

  ip_configuration {
    name = "redirector2-ip-config"
    subnet_id = azurerm_subnet.default_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.redirector2_public_ip.id
  }
}
resource "azurerm_network_interface_security_group_association" "redirector2_nic_ngs" {
  network_interface_id = azurerm_network_interface.redirector2_nic.id
  network_security_group_id = azurerm_network_security_group.redirector_nsg.id
}

# Define Network Interface for TeamServer (C2)
resource "azurerm_network_interface" "teamserver_nic" {
  name                = "teamserver-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]

  ip_configuration {
    name = "teamserver-ip-config"
    subnet_id = azurerm_subnet.default_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.teamserver_public_ip.id 
  }
}
resource "azurerm_network_interface_security_group_association" "teamserver_nic_nsg" {
  network_interface_id = azurerm_network_interface.teamserver_nic.id
  network_security_group_id = azurerm_network_security_group.teamserver_nsg.id
}

# Define Network Interface for Evilingx
resource "azurerm_network_interface" "Evilingx_nic" {
  name                = "Evilingx-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_resource_group.main]

  ip_configuration {
    name = "Evilingx-ip-config"
    subnet_id = azurerm_subnet.default_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.Evilingx_public_ip.id
  }
}
resource "azurerm_network_interface_security_group_association" "Evilingx_nic_nsg" {
  network_interface_id = azurerm_network_interface.Evilingx_nic.id
  network_security_group_id = azurerm_network_security_group.evilingx_nsg.id
}
