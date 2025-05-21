###################################################################################################
# Script Name: variables.tf
# Description: This is the variables.tf (TerraForm) script - this script is the central housing of all variables. 
# Author: Athanasius of Alexandria
# Copyright (C) 2025 AthanasiusXOR (Red Team Security Engineer)
#
# Version: 1.0.0
# Version History
#   1.0.0   2025-06-01  Initial version
#   
#
####################################################################################################

# This is the "variables.tf," where we identify the variables that are used throughout the build. If changes to "resource group" or passwords are to be made, this is the place to do it.
# For more information, please see the README.txt.
# Identify the location of the Azure VM Region.
variable "location" {
  description = "Azure region for deployment"
  type = string
  default = "East US"
}
# Identify the username for the Virtual Machines. Some will be "password" and other "SSH Key" for logon. Check the main.tf for the full list of VMs and how a user authenticates.
variable "username" {
  description = "Admin username for VMs"
  type = string
  default = "Jesus_Christ" # Can be changed, shooter preferrence. 
}
# Identify the size of the Virtual Machine. This is a default across the board. 
# This set-up is 2 vcpus, 8GiB memory.
variable "vm_size" {
  description = "VM size for the virtual machines"
  type = string
  default = "Standard_D2s_v3"
}
# This identifies the SSH PUblic Keys.
# Make sure that all public keys are stored correctly in Azure. 
variable "ssh_public_keys" {
  description = "File path for SSH public key"
  type = list(string)
  default = [
    "Path/to/Public/Key", 
    "Path/to/Public/Key", 
    "Path/to/Public/Key"
    ] # Have more than one, then you will just [./sshkey1.pub, ./sshkey2.pub]. Nomenclature for public keys should be the Operator's Last Name. 
}
variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type = string
  default = "Kingdom_of_Heaven" # The resource_group_name should be the name of the current operation. 
}
# Define the password for the Windows VM administrators.
variable "windows_admin_password" {
  description = "The admin passwrod for the Windows Virtual Machine."
  type = string
  default = "Jesus_Is_Lord" # This can/needs to be changed per deployment. For Windows RDP-only.
  sensitive = true
}
