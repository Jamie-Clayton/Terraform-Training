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
choco install postman

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


# 6. Walkthrough - Aws

TBA

# 7. Conclusion

TBA

## Working around Terraform limitations

The terraform providers may not impliment the complete range of API's available in each of the cloud providers. You can fallback to the powershell CLI commands to complete tasks. However the execution of those scripts will required the underlying terraform CICD pipeline to include the powershell scripts required.
