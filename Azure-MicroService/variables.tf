# Replace 00000000-00000-0000-0000-000000000000 with actual values
variable "azSubscriptionId" {
    type    = "string"
    default = "00000000-00000-0000-0000-000000000000"
}

variable "azTenantId" {
    type    = "string"
    default = "00000000-00000-0000-0000-000000000000"
}

variable "Env" {
    type    = "string"
    default = "develop"
}

variable "azLocation" {
    type = "string"
    default = "australiasoutheast"
}

variable "azDefaultDevTags" {
    type    = map(any)
    default = {
        Application-type    = "Microsoft Dot Net"
        Commercials         = "TBA"
        CostCenter          = "CustomerAccNumber=TBA"
        Documentation       = "https://github.com/JenasysDesign/Terraform-Training"
        Environment         = "dev",       
        Kanban              = "https://github.com/JenasysDesign/Terraform-Training/projects"
        Management          = "Terraform.azurerm",
        Solution            = "Cloud Microservices Template"
        Support             = "https://github.com/JenasysDesign/Terraform-Training/issues"
        Repository          = "https://github.com/JenasysDesign/Terraform-Training"
    }
}