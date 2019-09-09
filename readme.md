# Windows Configuration

## Objectives

1. Setup windows for Terraform infrastructure.
2. Determine the process/lifecycle for Terraform.                     
3. Evaluate the effort required.                                       
4. Walkthrough - Azure.
5. Walkthrough - Aws.
6. Conclusion. 

# 1. Setup
## Install Terraform software
Install chocolatey powershell package installer. https://chocolatey.org/install. 

```powershell
# ** Open powershell as admininistrator

# Install Chocolatey package manager
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# ** Reboot powershell as admininistrator

# Install Terraform editing software
choco install vscode

# Install CLI components needed for Terraform
choco install Terraform
choco install azure-cli
choco install awscli

# ** Reboot powershell as admininistrator
# ** Confirm installation versions are appropriate/current
choco -v
Terraform -v
az -v
aws --v
```

## Upgrading Terraform software

```powershell
# ** Open powershell as admininistrator

# VSCode will self update (but just in case)
choco upgrade vscode

# Upgrade CLI software (periodically)
choco upgrade Chocholatey
choco upgrade Terraform
choco upgrade azure-cli
choco upgrade awscli
```

# 2. Terraform lifecycle

1. Identify the cloud object to automate.
2. Find the matching Terraform Import command.
3. Run the command and review terminal output as well as *.tfstate.
4. Adjust the main.tf, variable.tf, output.tf etc files accordingly.
5. Confirm the configuration.
6. Determine if the further changes are required (Yes - GOTO step 1.)
6. Commit configuration to repo.

## Authoring Terraform projects
* Open Visual Code
* Navigate -> File -> Open Folder
* Create a new folder for your infrastructure as code files
* Initialize the folder as a Git Repository
* Create 3 file, that is the convention for Terraform implimentations
  * main.tf
  * variables.tf
  * outputs.tf
* Create a readme.md file

```powershell
# Initialize the directory that contains the terraform files
terraform init
```

When terraform runs, it automatically imports all the *.tf files and merges them together to execute. As a result all the variable declarations must be globaly unique.

# Configuration in Terraform
Once the terraform.tfstate file has been created you can edit all your *.tf files and compare that against the cloud environment. Terraform will report all the changes it will make if you apply the changes to the environment.

```powershell
# Terraform command lifecycle

# Confirm the script syntax
terraform validate

# Check the impact of the changes
terraform plan

# Apply the changes to your Cloud Environment (Updates *.tfState)
terraform apply

# Remove any Cloud infrastructure via terraform (Removes resource and costs associated)
terraform destroy
```

* The output compares the infrastructure defined in the *.tf files against the actual cloud infrastructure and will indicate how changes will impact that system.
* Changing the Cloud infrastructure required running.
* Removing the infrastructure created via the destroy option. https://www.terraform.io/docs/commands/destroy.html

# 4. Terraform Effort->Reward Tradeoff

TBA 

# 5. Walkthrough - Azure

The following example is a basic set of .net components that would be required for creating a basic .net microservice using queues, file storage and a SQL database for a development environment. Some of these objects may already exist in Azure, so you can use them to start the process.

## Azure - Find Subscription details
* Open Visual Code (Reboot if extensions were installed)
* Navigate to Terminal -> New Terminal -> Terminal Tab 
* Enter the following command one at a time.

```powershell
# Web browser will open and navigate through the Azure Portal authentication process
az login

# You can then view all the azure subscriptions you user/password combo can access.
az account list

# Replace SUBSCRIPTION_ID in the powershell bellow, with the GUID from the previous step.
az account set -s SUBSCRIPTION_ID
az account show
```

## Azure - Existing Cloud Objects

1. Open Azure portal and identify the object to import
2. Using the portal.azure.com Navigate to object -> Find "Export Template" sub menu -> Click on "CLI" tab.
3. Review 
4. Find the matching Terraform azure provider command to create the object.
5. Create the *.tf object 
6. Use the Terraform cli to import the object
7. Confirm the *.tf configuration matches the imported object

### Terraform Import (Existing cloud objects)

```powershell
# Replace SUBSCRIPTION_ID in this script
# Import an existing cloud object into terraform.tfstate file
# Allows you to modify existing manual Azure items, so they become terraform managed.

# Resource Group example
terraform import azurerm_resource_group.group /subscriptions/SUBSCRIPTION_ID/resourceGroups/develop-rg

# Note: The child security objects and queue do not get created.
# See - azurerm_servicebus_namespace_authorization_rule for important security settings 
#       was discovered later during software testing the terraform resources.
terraform import azurerm_servicebus_namespace.queue /subscriptions/SUBSCRIPTION_ID/resourceGroups/develop-rg/providers/microsoft.servicebus/namespaces/develop-sbus

# Storage Account
terraform import azurerm_storage_account.storage /subscriptions/SUBSCRIPTION_ID/resourceGroups/develop-rg/providers/Microsoft.Storage/storageAccounts/developstorage
```

### File Example - main.tf 
\>= 0.12

```terraform
# Configure the Azure Provider
provider "azurerm" {
  version = "=1.28.0"
  subscription_id = var.azSubscriptionId
  tenant_id       = var.azTenantId
}

# Resource Group to store all the related objects.
resource "azurerm_resource_group" "envgrp" {  
  name      = join("-", [var.Env, "rg"] )
  location  = var.azLocation
  tags      = var.azDefaultDevTags
}

# Queue services for Producer/Consumer software pattern.
resource "azurerm_servicebus_namespace" "queue" {
  name                = join("-", [ var.Env, "sbus" ] )
  resource_group_name = azurerm_resource_group.envgrp.name
  location            = azurerm_resource_group.envgrp.location
  sku                 = "Standard"
  tags                = var.azDefaultDevTags
}

resource "azurerm_servicebus_namespace_authorization_rule" "queuesecurity" {
  name                = "RootManageSharedAccessKey"
  namespace_name      = azurerm_servicebus_namespace.queue.name
  resource_group_name = azurerm_resource_group.envgrp.name

  listen = true
  send   = true
  manage = true
}

# Storeage account (LowerCaseOnly)
resource "azurerm_storage_account" "storage" {
  name                     = lower(join( var.Env, "storage" ))
  resource_group_name      = azurerm_resource_group.envgrp.name
  location                 = azurerm_resource_group.envgrp.location
  access_tier              = "Hot"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  enable_https_traffic_only = true
  tags                     = var.azDefaultDevTags
}

# Create Storage and share for portal.azure.com Shell commands (Powershell/Bash)
resource "azurerm_storage_account" "shellstorage" {
  name                     = lower(join( "shell", "storage" ))
  resource_group_name      = azurerm_resource_group.envgrp.name
  location                 = "Southeast Asia"
  access_tier              = "Hot"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
  tags                     = merge({ ms-resource-usage = "azure-cloud-shell" }, var.azDefaultDevTags)
}

# Exposing a share required for portal.azure.com Shell commands (Powershell/Bash)
# TODO - Unsure of the security implications of this
resource "azurerm_storage_share" "shellShare" {
  name                 = "powershell"
  storage_account_name = azurerm_storage_account.shellstorage.name
  resource_group_name  = azurerm_resource_group.envgrp.name
  quota                = 2
}
```
### File Example - variables.tf
\>= 0.12

```terraform
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
```

### File Example - Output.tf
```Terraform
output "StorageKey" {
    value = azurerm_storage_account.storage.primary_access_key
}

output "StorageName" {
    value = azurerm_storage_account.storage.name
}

output "ServiceBusConnectionString" {
    value = azurerm_servicebus_namespace_authorization_rule.queuesecurity.primary_connection_string
}

output "FileShare-Shell" {
    value = azurerm_storage_share.shellShare.url
} 
```
# 6. Walkthrough - Aws

TBA

# 7. Conclusion

>  “Infrastructure as code is an approach to managing IT infrastructure for the age of cloud, microservices and continuous delivery.” – Kief Morris, head of continuous delivery for ThoughtWorks Europe.

1. Automate/Code everything
2. Document as little as possible
3. Maintain with version control
4. Continuously test, integrate, and deploy
5. Make your infrastructure code modular
6. Make your infrastructure immutable (cattle not pets)

## Working around Terraform limitations

The terraform providers may not impliment the complete range of API's available in each of the cloud providers. You can fallback to the powershell CLI commands to complete tasks. However the execution of those scripts will required the underlying terraform CICD pipeline to include the powershell scripts required.

## Further Reading

[Wikipedia](https://en.wikipedia.org/wiki/Infrastructure_as_code)

[Infrastructure as Code - O'Reilly book](https://infrastructure-as-code.com/)

[Infrastructure as code - Hashicorp](https://www.hashicorp.com/products/terraform/infrastructure-as-code)

[Multi-Cloud Compliance - Hashicorp](https://www.hashicorp.com/products/terraform/multi-cloud-compliance-and-management)

[Cloud agnostic IAC structures - Github](https://github.com/kief/spin-template-standalone-service)