variable "location" {
  type    = string
  default = "uaenorth"
}
variable "prefix" {
  type    = string
  default = "terraform"
}

variable "vmuser" {
  type    = string
  default = "ubuntu_user"
}

variable "source-address" {
  type    = string
  default = "*"
}