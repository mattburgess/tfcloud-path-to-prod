# Configure Terraform for Local Runs

At this early stage, all we want to do is ensure that `terraform`, when run locally, can initialize itself and run successfully but not manage any resources.

Copy and paste the following Terraform code into a new file, `terraform.tf`, which will configure the [Terraform Enterprise provider](https://github.com/hashicorp/terraform-provider-tfe). Terraform will use local state files to keep track of any resources that it is managing.

```hcl
{{#include terraform.tf}}
```

Copy and paste the following Terraform code into a new file, `variables.tf`, which declares the input variables we set up earlier in `credentials.auto.tfvars`

```hcl
{{#include variables.tf}}
```

Initialize Terraform:

```sh
$ terraform init

Initializing the backend...

Initializing provider plugins...

- Finding hashicorp/tfe versions matching "~> 0.48.0"...
- Installing hashicorp/tfe v0.48.0...
- Installed hashicorp/tfe v0.48.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

At this point, a `terraform plan` should succeed but show no resources need to change, somewhat obviously due to us not having asked it to manage any just yet:

```sh
$ terraform plan

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
