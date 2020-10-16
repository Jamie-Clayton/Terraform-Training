# Simple Azure Single Page Application Web site

Initial Terraform code that has been configured without testing in the azure platform.
Applies a template Google AMP template to the html files added.

## Process

- [ ] Read [Microsoft CDN configuration](https://docs.microsoft.com/en-us/azure/cdn/cdn-create-new-endpoint)
- [ ] Watch [Static web pages in Azure storage](https://www.youtube.com/watch?v=G_gDYlRBAZw)
- [ ] Learn terraform CLI
- [ ] Review variables.tf and particularly, the names of objects.

```powershell

# Navigate to the project folder
cd ~\OneDrive\Documents\Terraform\Terraform-Training\Azure-Spa

# Initialize the directory that contains the terraform files
terraform init

# Validate the files
terraform validate

# Check what will change
terraform plan

# Apply the changes to Azure
terraform apply -auto-approve

# Remove all the Azure Resource Group objects
terraform destroy
```

## References

[Terraform - Azure storage](https://www.terraform.io/docs/providers/azurerm/r/storage_account.html)

[Terraform - Azure CDN Profile](https://www.terraform.io/docs/providers/azurerm/r/cdn_profile.html)

[Terraform - Azure CDN Endpoint](https://www.terraform.io/docs/providers/azurerm/r/cdn_endpoint.html)

[Terraform - Modules](https://www.terraform.io/docs/configuration/modules.html)

[Terraform - Locals](https://www.terraform.io/docs/configuration/locals.html)

[Terraform - Variables](https://www.terraform.io/docs/configuration/variables.html)
