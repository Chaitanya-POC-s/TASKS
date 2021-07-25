# Variable Declaration for Resource group name
variable "resource_group_name" {
}

# Variable Declaration for Region
variable "region" {
  }

# Variable Declaration for Virtual Network Enable
variable "vnet_enable" {
  
}

# Variable Declaration for Virtual Network Name
variable "vnet_name" {
   type = list(string)
}

# Variable Declaration for Virtual Network Address
variable "vnet_address" {
    type = list(string)
}



# Variable Declaration for Tag Value
variable "tagvalue" {
  type = map(string)
}

# Variable Declaration for Environment
variable "environment" {
}
