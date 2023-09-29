# Configure Terraform for Local Runs

At this early stage, all we want to do is ensure that `terraform`, when run locally, can initialize itself and run successfully but not manage any resources.

Copy and paste the following Terraform code into a new file, `terraform.tf`, which will configure the [Terraform Enterprise provider](https://github.com/hashicorp/terraform-provider-tfe), [AWS provider](https://github.com/hashicorp/terraform-provider-aws), and [GitHub provider](https://github.com/integrations/terraform-provider-github). Terraform will use local state files to keep track of any resources that it is managing.

```hcl
{{#include terraform/terraform.tf}}
```

Copy and paste the following Terraform code into a new file, `variables.tf`, which declares the input variables we set up earlier in `credentials.auto.tfvars`

```hcl
{{#include terraform/variables.tf}}
```

Initialize Terraform:

```sh
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.19.0"...
- Finding hashicorp/tfe versions matching "~> 0.48.0"...
- Finding integrations/github versions matching "~> 5.38.0"...
- Installing hashicorp/aws v5.19.0...
- Installed hashicorp/aws v5.19.0 (signed by HashiCorp)
- Installing hashicorp/tfe v0.48.0...
- Installed hashicorp/tfe v0.48.0 (signed by HashiCorp)
- Installing integrations/github v5.38.0...
- Installed integrations/github v5.38.0 (signed by a HashiCorp partner, key ID 38027F80D7FD5FB2)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
```

At this point, a `terraform plan` should succeed but show no resources need to change, somewhat obviously due to us not having asked it to manage any just yet:

```sh
$ terraform plan

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
