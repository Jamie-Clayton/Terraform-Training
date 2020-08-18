# Replace 00000000-00000-0000-0000-000000000000 with actual values
variable azSubscriptionId {
    type    = string
    default = "00000000-00000-0000-0000-000000000000"
}

variable azTenantId {
    type    = string
    default = "00000000-00000-0000-0000-000000000000"
}

locals {
  org      = "acai"
  prj      = "icecreamery"
  env      = "dev"
  location = "australiaeast"
}

variable azDefaultTags {
    type    = map(any)
    default = {
        Application-type    = "Microsoft Dot Net"
        Commercials         = "Creative Commons"
        CostCenter          = "CustomerAccNumber=54321"
        Documentation       = "https://github.com/Jamie-Clayton/Terraform-Training"
        Environment         = "$(local.env)",       
        Kanban              = "https://github.com/Jamie-Clayton/Terraform-Training/projects"
        Management          = "Terraform.azurerm",
        Solution            = "Cloud Microservices Template"
        Support             = "https://github.com/Jamie-Clayton/Terraform-Training/issues"
        Repository          = "https://github.com/Jamie-Clayton/Terraform-Training"
    }
}

resource "random_string" "suffix" {
  length  = 13
  upper   = false
  special = false
  keepers = {
    location = local.location
  }
}

# https://medium.com/gsoft-tech/azure-resource-naming-conventions-in-terraform-c33693171ad8
# https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging

module "resource_group_name" {
  source   = "gsoft-inc/naming/azurerm//modules/general/resource_group"
  name     = "main"
  prefixes = ["rg",local.org, local.prj, local.env]
  suffixes = [random_string.suffix.result]
}

module "storage_account_name" {
  source   = "gsoft-inc/naming/azurerm//modules/storage/storage_account"
  name     = "data"
  prefixes = ["st",local.org, local.env]
}

module "shell_storage_account_name" {
  source   = "gsoft-inc/naming/azurerm//modules/storage/storage_account"
  name     = "shell"
  prefixes = ["st",local.org, local.env]
  suffixes = [random_string.suffix.result]
}