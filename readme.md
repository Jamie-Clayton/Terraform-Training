# Terraform Windows Configuration and Introduction

## Table Of Contents

1. Setup
2. Terraform life cycle.
3. Terraform Effort versus Reward Tradeoff.
4. Terraform Walk-through - Azure.
5. Terraform Walk-through - Aws.
6. Terraform Object Naming Recommendations
7. Conclusion
8. Further Reading

## 1. Setup

### Install Terraform software on Windows

Install chocolatey powershell package installer. [Chocolatey Package Management](https://chocolatey.org/)

```powershell
# Open powershell as administrator
# Install Chocolatey first
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Terraform editing software
choco install vscode -y

# Install infrastructure as code tool - Terraform.io and Packer.io
choco install terraform -y
choco install packer -y
choco install azure-cli -y
choco install awscli -y

# Run an updated on Terraform related components
choco upgrade vscode chocolatey terraform packer azure-cli awscli -y

# Confirm Installation editions
choco -v
Terraform -v
az -v
aws --v

# Navigated to Terraform folders
$terraformPath = "~\OneDrive\Documents\Terraform\"
New-Item -Path $terraformPath -Type Directory
Push-Location $terraformPath

# Open Microsoft Visual Code with the active folder loaded
Code . -n

Pop-Location
# Review Terraform Extensions (currently they have not been ported to Chocolately installations)
Write-Output("Review Extensions - Terraform")
```

## Upgrading Terraform software on Windows

```powershell
# Open powershell as administrator
choco upgrade vscode chocolatey terraform packer azure-cli awscli -y
```

### Install Terraform software on Linux

Initially I hoped to use the SnapCraft universal linux packaging solution. At the time of authoring this guide, it was not installing the current editions desired.

#### Linux Snap repository

```bash
sudo snap install terraform

# Confirm the edition of terraform
terraform -v

sudo snap remove terraform

# Confirm Snap removed (snap directory found in $PATH)
ls /snap/bin
```

#### Linux manual installation

These are instructions from a windows software engineering perspective.

```bash
# Create terraform storage directories
mkdir ~/Public/terraform
cd ~/Public/terraform/

# Add the installation directory to the executable $PATH
echo $PATH
export PATH=~/Public/terraform/:$PATH
# Confirm the $PATH now includes terraform directory
echo $PATH

# Navigate in a browser to Terraform downloads to obtain the URL for the latest edition
# https://www.terraform.io/downloads.html
curl -o ~/Downloads/terraform.zip https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip
unzip -u ~/Downloads/terraform.zip -d ~/Public/terraform/

# Read - https://superuser.com/a/183980

# Set your terminal perminantly (via Microsoft Visual Code)
# Select one of the following 3 options (Add/Remove # comment at start of the line)

#code ~/.profile
#code ~/.bash_profile
code ~/.bashrc  

# add the following lines to the end of the document

export PATH=~/Public/terraform/:$PATH
alias tf='terraform'

# Save and close file in Visual Code

# Load the current bash session with the profile values.
source ~/.profile

# Confirm the edition of Terraform installed.
terraform -v

# Create an alias command for Terraform application
alias tf='terraform'

# Test the alias works
tf -v
```

[Installation Video - HashiCorp](https://learn.hashicorp.com/terraform/getting-started/install)

### Upgrading Terraform software on Linux

Please update the values in the script below as needed.

```bash
# Navigate in a browser to Terraform downloads to obtain the URL for the latest edition
# https://www.terraform.io/downloads.html
curl -o ~/Downloads/terraform.zip https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip
unzip -u ~/Downloads/terraform.zip -d ~/Public/terraform/
```

## 2. Terraform life cycle

1. Identify the cloud object to automate.
2. Find the matching Terraform Import command.
3. Run the command and review terminal output as well as *.tfstate.
4. Adjust the main.tf, variable.tf, output.tf etc files accordingly.
5. Confirm the configuration.
6. Determine if the further changes are required (Yes - GOTO step 1.)
7. Commit configuration to repo.

### Authoring Terraform projects

* Open Visual Code
* Navigate -> File -> Open Folder
* Create a new folder for your infrastructure as code files
* Initialize the folder as a Git Repository
* Create 3 file, that is the convention for Terraform implementations
  * main.tf
  * variables.tf
  * outputs.tf
* Create a readme.md file

```powershell
# Initialize the directory that contains the terraform files
terraform init
```

When terraform runs, it automatically imports all the *.tf files and merges them together to execute. As a result all the variable declarations must be globally unique.

### Configuration in Terraform

Once the terraform.tfstate file has been created you can edit all your *.tf files and compare that against the cloud environment. Terraform will report all the changes it will make if you apply the changes to the environment.

```powershell
# Terraform command life cycle

# Confirm the script syntax
terraform validate

# Check the impact of the changes
terraform plan

# Apply the changes to your Cloud Environment (Updates *.tfState)
terraform apply

# Remove any Cloud infrastructure via terraform (Removes resource and costs associated)
terraform destroy
```

The output compares the infrastructure defined in the *.tf files against the actual cloud infrastructure and will indicate how changes will impact that system. The terraform state files generated allow configuration drift to be detected, so manual changes to cloud environments can be monitored and appropriate action taken.

## 3. Terraform Effort versus Reward Tradeoff

### Effort

* Upfront investment

  * secrets governance
  * source control governance
  * deployment pipelines service configuration
  * terraform state file storage
  * staff training (git/terraform/cli)

* Component investment

  * Each Object takes about 5-30 minutes to setup in terraform
  * Portal editing or powershell CLI object creation takes up to 5 minutes to step through
  * Execution time slightly longer with Terraform and Azure
  * Slower initial environment configuration.

* Technical Debt

  * Terraform CLI and Provider CLI updates may require reviewing/testing existing files
  * Duplication of patching effort that may be automated by providers user interfaces
  * Infrastructure drift (manual changes conflict with file settings).

### Rewards

Requires multiple re-use of Terraform files (templates/modules) before the reward is greater than the effort invested in the approach.

* Infrastructure as code governance model
* Control/consistency of environments. E.g. (dev, uat, prod)
* Versioning of infrastructure changes
* Reduced data entry and human factors
* Reusable patterns, via modules (Repository of infrastructure)
* Automatic documentation
* Naming consistency
* Enables extensive tagging, useful for reporting, managing costs, searching

## 4. Terraform Walk-through - Azure

The following example is a basic set of .net components that would be required for creating a basic .net [Microservice](https://en.wikipedia.org/wiki/Microservices)  using queues, file storage and a SQL database for a development environment. Some of these objects may already exist in Azure, so you can use them to start the process.

### Azure - Find Subscription details

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

### Azure - Existing Cloud Objects

1. Open Azure portal and identify the object to import
2. Find the matching Terraform azure provider command to create the object. See [Terraform Azure Documents](https://www.terraform.io/docs/providers/azurerm/) and use the **Filter** feature.
3. Add the object reference in the  main.tf file. E.g. resource "azurerm_resource_group" "grpName" {}
4. Use the Terraform cli to import the object (step 2 web page #import bookmark). E.g. terraform import azurerm_resource_group.group /subscriptions/SUBSCRIPTION_ID/resourceGroups/develop-rg
5. Run the Terraform cli command to review the change. E.g. terraform plan
6. Confirm the main.tf configuration matches the imported object (from step 5)

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

# Storage account (LowerCaseOnly)
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

## 5. Walk-through - Aws

TBA

## 6. Terraform Object Naming Recommendations

* **Do** Keep your naming pattern consistent.
* **Do** consider how people will infer things from the name.
* **Don't** use a terraform providers name in the object names. E.g. *AWS-Backup-Storage* should be *Backup-Storage*
* **Don't** use provider specific service names. E.g. *EC2-Ordering-UI-WebServer* should be *Ordering-UI-WebServer*
* **Don't** use acronyms, unless they are part of you naming strategy E.g. *WS* should be *WebServer*
* **Do** use tags to provide more context for the objects.

### Naming Examples with Terraform Variables

A windows IIS Web Server: *SupplyChain-Orders-UAT-WebServer*

```Terraform
    var.Service = "SupplyChain"
    var.Component = "Orders"
    var.Environment = "UAT"
    var.ObjectName = "{var.Service}-{var.Component}-{var.Environment}-WebServer" 
```

## 8. Conclusion

> “Infrastructure as code is an approach to managing IT infrastructure for the age of cloud, Microservice and continuous delivery.” – Kief Morris, head of continuous delivery for ThoughtWorks Europe.

1. Automate/Code everything
2. Document as little as possible
3. Maintain with version control
4. Continuously test, integrate, and deploy
5. Make your infrastructure code modular
6. Make your infrastructure immutable (cattle not pets)
7. Feed the results through a governance pipeline

### Working around Terraform limitations

The terraform providers may not implement the complete range of API's available in each of the cloud providers. You can fallback to the powershell CLI commands to complete tasks. However the execution of those scripts will required the underlying terraform CICD pipeline to include the powershell scripts required.

## 9. Further Reading

[Wikipedia](https://en.wikipedia.org/wiki/Infrastructure_as_code)

[Infrastructure as Code - O'Reilly book](https://infrastructure-as-code.com/)

[Infrastructure as code - Hashicorp](https://www.hashicorp.com/products/terraform/infrastructure-as-code)

[Multi-Cloud Compliance - Hashicorp](https://www.hashicorp.com/products/terraform/multi-cloud-compliance-and-management)

[Cloud agnostic IAC structures - Github](https://github.com/kief/spin-template-standalone-service)
