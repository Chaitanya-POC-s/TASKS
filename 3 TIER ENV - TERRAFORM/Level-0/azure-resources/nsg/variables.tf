# Variable declaration for NSG Enable/Disable flag
variable "nsg_enable" {

}


# Variable declaration of resource group name where NSG gets created
variable "resource_group_name" {

}


# Variable declaration of region where NSG gets created
variable "region" {

}


# Variable declaration of Subnet's count used for creating NSGs
variable "subnet_count" {

}


# Variable declaration of the nams for NSGs
variable "nsg_name" {
    type = list(string)
}


# Variable declaration of Web layer rules for NSGs
variable "nsg_tier1_rules" {
  type= list(string)
}


# Variable declaration of App layer rules for NSGs
variable "nsg_tier2_rules" {
  type= list(string)
}


# Variable declaration of DB layer rules for NSGs
variable "nsg_tier3_rules" {
  type= list(string)
}


# Variable declaration for subnet ranges for NSG Rules
variable "subnet_range" {
  type = list(string)
}


# Variable declaration for adding Tags to be used for NSGs
variable "tagvalue" {
  type = map(string)
}


# Variable declaration for Environment value to be added
variable "environment" {

}