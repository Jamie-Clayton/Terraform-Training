# Windows Configuration

## Objectives

1. Setup windows for Terraform infrastructure.
2. Determine the process/lifecycle for Terraform.                     
4. Evaluate the effort required.                                       
4. Determine the business cost/value/reward of each script.

# 1. Setup
## Setup - Install software
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

## Setup - Upgrading software

```powershell
# ** Open powershell as admininistrator

# VSCode will self update (but just in case)
choco upgrade vscode
# Upgrade CLI software (periodically)
choco upgrade Chocholatey
choco upgrade Terraform
choco upgrade azure-cli
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

# Effort/Reward Tradeoff
