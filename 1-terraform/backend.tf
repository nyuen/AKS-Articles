terraform {
  backend "azurerm" {
    key                  = "demo.terraform.tfstate"
  }
}