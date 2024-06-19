variable "rg" {
    default = "tst-rg"
    type = "string"
  
}
variable "location" {
    default = "Central US"
  
}
variable "vnet" {
    default = "tst-vnet"
    type = "string"
  
}
variable "address_space" {
    default = ["10.0.0.0/16"]
    type = [list(string)]

}
variable "subnet" {
    default = ["10.0.0.0/26"]
    type = [list(string)]
  
}


