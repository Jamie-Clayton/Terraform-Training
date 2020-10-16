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
  org      = "jenasys"
  prj      = "icecreamery"
  env      = "dev"
  location = "australiaeast"
}

variable azDefaultTags {
    type    = map(any)
    default = {
        Application-type    = "Microsoft Dot Net"
        Commercials         = "Jenasys - Service - Landing Page"
        Documentation       = "https://github.com/Jamie-Clayton/Terraform-Training"
        Environment         = "$(local.env)",       
        Kanban              = "https://github.com/Jamie-Clayton/Terraform-Training/projects"
        Management          = "Terraform.azurerm",
        Solution            = "Cloud CDN SPA Template"
        Support             = "https://github.com/Jamie-Clayton/Terraform-Training/issues"
        Repository          = "https://github.com/Jamie-Clayton/Terraform-Training"
    }
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  keepers = {
    location = local.location
  }
}

module "resource_group_name" {
  source   = "gsoft-inc/naming/azurerm//modules/general/resource_group"
  name     = "cdn"
  prefixes = ["rg",local.prj, local.env]
  suffixes = [random_string.suffix.result]
}

module "storage_account_name" {
  source   = "gsoft-inc/naming/azurerm//modules/storage/storage_account"
  name     = "cdn"
  prefixes = [local.prj, local.env]
}

module "cdn_profile_name" {
  source   = "gsoft-inc/naming/azurerm//modules/storage/file_share_name"
  name     = "cdn"
  prefixes = [local.prj, local.env]
  suffixes = [random_string.suffix.result]
}

module "cdn_endpoint_name" {
  source   = "gsoft-inc/naming/azurerm//modules/general/resource_group"
  name     = "cdn"
  prefixes = [local.prj, local.env]
  suffixes = [random_string.suffix.result]
}