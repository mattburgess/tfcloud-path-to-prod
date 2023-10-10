# Configure OIDC Provider

In order to avoid having to create long-term credentials for Terraform Cloud to use so that it can make changes to your infrastructure we can configure Terraform Cloud to assume an IAM role instead.

Similarly to the previous chapter, we'll need to create some resources from our local machine until we've configured enough infrastructure to allow Terraform Cloud to take over management duties.

Clone the repository that was created in the last section:

```sh
git clone https://github.com/your-github-org/tfcloud-pipeline
cd tfcloud-pipeline
```

Firstly, we'll create a new module that will create the roles that Terraform Cloud will assume during its plan and apply runs.

Copy and paste the following into a new file, `modules/tfcloud_role/variables.tf`:

```hcl
{{#include terraform/modules/tfcloud_role/variables.tf}}
```

Copy and paste the following into a new file, `modules/tfcloud_role/main.tf`

```hcl
{{#include terraform/modules/tfcloud_role/main.tf}}
```

With the module in place, we can set up the root module, which will create the OIDC provider and associated IAM roles.

Copy and paste the following into a new file, `variables.tf`:

```hcl
{{#include terraform/variables.tf}}
```

Copy and paste the following into a new file, `terraform.tf`:

```hcl
{{#include terraform/terraform.tf}}
```

Next, copy and paste the following into a new file, `main.tf`:

```hcl
{{#include terraform/main.tf}}
```

Next, copy and paste the following into a new file, `tfcloud_pipeline.auto.tfvars`:

```hcl
{{#include terraform/tfcloud_pipeline.auto.tfvars}}
```

Run `terraform init`:

```sh
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.20.0"...
- Installing hashicorp/aws v5.20.0...
- Installed hashicorp/aws v5.20.0 (signed by HashiCorp)

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

We'll need to create the roles for every workspace so that Terraform Cloud can assume them for their plan and apply runs. We'll start off in the pre-dev eu-west-2 workspace so that the OIDC provider is created:

```sh
$ terraform workspace new tfcloud-pipeline-pre-dev-eu-west-2
Created and switched to workspace "tfcloud-pipeline-pre-dev-eu-west-2"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

Now we'll create the OIDC provider separately from the rest of the resources. This is required because there's an `aws_openid_connect_provider` data source in the `tfcloud_role`; running a `terraform apply` without a matching data source in AWS will error.

Run `terraform apply -target aws_iam_openid_connect_provider.tfcloud` to create the OIDC provider in your AWS account:

```sh
$ terraform apply -target aws_iam_openid_connect_provider.tfcloud

...
Terraform will perform the following actions:

  # aws_iam_openid_connect_provider.tfcloud[0] will be created
  + resource "aws_iam_openid_connect_provider" "tfcloud" {
      + arn             = (known after apply)
      + client_id_list  = [
          + "aws.workload.identity",
        ]
      + id              = (known after apply)
      + tags_all        = (known after apply)
      + thumbprint_list = [
          + "9e99a48a9960b14926bb7f3b02e22da2b0ab7280",
        ]
      + url             = "https://app.terraform.io"
    }

Plan: 1 to add, 0 to change, 0 to destroy.
╷
│ Warning: Resource targeting is in effect
│ 
│ You are creating a plan with the -target option, which means that the result of this plan may not represent all of the changes requested by
│ the current configuration.
│ 
│ The -target option is not for routine use, and is provided only for exceptional situations such as recovering from errors or mistakes, or when
│ Terraform specifically suggests to use it as part of an error message.
╵

Do you want to perform these actions in workspace "tfcloud-pipeline-pre-dev-eu-west-2"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_iam_openid_connect_provider.tfcloud[0]: Creating...
aws_iam_openid_connect_provider.tfcloud[0]: Creation complete after 1s [id=arn:aws:iam::012345678901:oidc-provider/app.terraform.io]
╷
│ Warning: Applied changes may be incomplete
│ 
│ The plan was created with the -target option in effect, so some changes requested in the configuration may have been ignored and the output
│ values may not be fully updated. Run the following command to verify that no other changes are pending:
│     terraform plan
│  
│ Note that the -target option is not suitable for routine use, and is provided only for exceptional situations such as recovering from errors
│ or mistakes, or when Terraform specifically suggests to use it as part of an error message.
╵

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

```

````admonish warning
You may encounter the following error if you haven't configured your AWS credentials correctly from the [pre-requisites](../tfcloud-setup/pre-requisites.md#aws-credentials) section:

```text
Planning failed. Terraform encountered an error while generating this plan.

╷
│ Error: No valid credential sources found
│ 
│   with provider["registry.terraform.io/hashicorp/aws"],
│   on terraform.tf line 10, in provider "aws":
│   10: provider "aws" {
│ 
│ Please see https://registry.terraform.io/providers/hashicorp/aws
│ for more information about providing credentials.
│ 
│ Error: failed to refresh cached credentials, no EC2 IMDS role found, operation error
│ ec2imds: GetMetadata, request canceled, context deadline exceeded
```

If you haven't saved credentials in your default profile, you may need to `export AWS_PROFILE=your-profile-name` prior to running `terraform apply`
````

With the OIDC provider now in place, we can run a full `terraform apply` to create the IAM roles and attach the required policies to them:

```sh
$ terraform apply
module.tfcloud_pipeline_roles.data.aws_iam_openid_connect_provider.tfcloud: Reading...
aws_iam_openid_connect_provider.tfcloud[0]: Refreshing state... [id=arn:aws:iam::320797911953:oidc-provider/app.terraform.io]
module.tfcloud_pipeline_roles.data.aws_iam_openid_connect_provider.tfcloud: Read complete after 0s [id=arn:aws:iam::320797911953:oidc-provider/app.terraform.io]
module.tfcloud_pipeline_roles.data.aws_iam_policy_document.tfcloud_pipeline_plan_assume_role: Reading...
module.tfcloud_pipeline_roles.data.aws_iam_policy_document.tfcloud_pipeline_apply_assume_role: Reading...
module.tfcloud_pipeline_roles.data.aws_iam_policy_document.tfcloud_pipeline_apply_assume_role: Read complete after 0s [id=595414985]
module.tfcloud_pipeline_roles.data.aws_iam_policy_document.tfcloud_pipeline_plan_assume_role: Read complete after 0s [id=4136116602]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
...
module.tfcloud_pipeline_roles.aws_iam_role.tfcloud_pipeline_apply: Creating...
module.tfcloud_pipeline_roles.aws_iam_role.tfcloud_pipeline_plan: Creating...
module.tfcloud_pipeline_roles.aws_iam_role.tfcloud_pipeline_apply: Creation complete after 1s [id=tfcloud-pipeline-pre-dev-eu-west-2-apply]
module.tfcloud_pipeline_roles.aws_iam_role_policy_attachment.tfcloud_pipeline_apply[0]: Creating...
module.tfcloud_pipeline_roles.aws_iam_role_policy_attachment.tfcloud_pipeline_apply[1]: Creating...
module.tfcloud_pipeline_roles.aws_iam_role.tfcloud_pipeline_plan: Creation complete after 1s [id=tfcloud-pipeline-pre-dev-eu-west-2-plan]
module.tfcloud_pipeline_roles.aws_iam_role_policy_attachment.tfcloud_pipeline_plan[1]: Creating...
module.tfcloud_pipeline_roles.aws_iam_role_policy_attachment.tfcloud_pipeline_plan[0]: Creating...
module.tfcloud_pipeline_roles.aws_iam_role_policy_attachment.tfcloud_pipeline_apply[0]: Creation complete after 0s [id=tfcloud-pipeline-pre-dev-eu-west-2-apply-20231008194953744100000001]
module.tfcloud_pipeline_roles.aws_iam_role_policy_attachment.tfcloud_pipeline_apply[1]: Creation complete after 0s [id=tfcloud-pipeline-pre-dev-eu-west-2-apply-20231008194953786500000002]
module.tfcloud_pipeline_roles.aws_iam_role_policy_attachment.tfcloud_pipeline_plan[1]: Creation complete after 0s [id=tfcloud-pipeline-pre-dev-eu-west-2-plan-20231008194953905700000003]
module.tfcloud_pipeline_roles.aws_iam_role_policy_attachment.tfcloud_pipeline_plan[0]: Creation complete after 0s [id=tfcloud-pipeline-pre-dev-eu-west-2-plan-20231008194954014200000004]
```

## Create Roles for all Workspaces

We'll now need to go around the remaining workspaces and create the roles necessary for Terraform Cloud to be able to run correctly.

```sh
$ terraform workspace new tfcloud-pipeline-dev-eu-west-2
$ sed -i 's/pre-dev/dev/' tfcloud_pipeline.auto.tfvars
$ terraform apply
...
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

$ terraform workspace new tfcloud-pipeline-test-eu-west-2
$ sed -i 's/dev/test/' tfcloud_pipeline.auto.tfvars
$ terraform apply
...
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

$ terraform workspace new tfcloud-pipeline-prod-eu-west-2
$ sed -i 's/test/prod/' tfcloud_pipeline.auto.tfvars
$ terraform apply
...
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
```

## Migrate Local State To Terraform Cloud

Just as we had to in the last chapter, we'll need to let Terraform Cloud take ownership of the state information for the above resources. We can let Terraform migrate all of our local workspaces in one go by using `tags` instead of explicitly naming the target workspace.

Edit `terraform.tf`, adding the following inside the existing `terraform {}` block:

```hcl
terraform {
  ...
  cloud {
    organization = "your_tfcloud_org_name"

    workspaces {
      tags = [
        "tfcloud-pipeline",
      ]
    }
  }
}
```

Initialize Terraform again, and confirm that you want the current (local) state to be migrated to the Terraform Cloud Workspace:

```sh
$ terraform init

Initializing Terraform Cloud...
Would you like to rename your workspaces?
  Unlike typical Terraform workspaces representing an environment associated with a particular
  configuration (e.g. production, staging, development), Terraform Cloud workspaces are named uniquely
  across all configurations used within an organization. A typical strategy to start with is
  <COMPONENT>-<ENVIRONMENT>-<REGION> (e.g. networking-prod-us-east, networking-staging-us-east).
  
  For more information on workspace naming, see https://www.terraform.io/docs/cloud/workspaces/naming.html
  
  When migrating existing workspaces from the backend "local" to Terraform Cloud, would you like to
  rename your workspaces? Enter 1 or 2.
  
  1. Yes, I'd like to rename all workspaces according to a pattern I will provide.
  2. No, I would not like to rename my workspaces. Migrate them as currently named.

  Enter a value: 2

Migration complete! Your workspaces are as follows:
  tfcloud-pipeline-dev-eu-west-2
  tfcloud-pipeline-pre-dev-eu-west-2
* tfcloud-pipeline-prod-eu-west-2
  tfcloud-pipeline-test-eu-west-2

Initializing modules...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.20.0

Terraform Cloud has been successfully initialized!

You may now begin working with Terraform Cloud. Try running "terraform plan" to
see any changes that are required for your infrastructure.

If you ever set or change modules or Terraform Settings, run "terraform init"
again to reinitialize your working directory.

```

With the state migration complete, you can safely remove the `cloud{}` block that was temporarily added above; this is ignored by Terraform Cloud when the workspace is being managed by a VCS integration like GitHub.

## Commit Code

As with the `tfcloud-mgmt` repository, the `main` branch in the `tfcloud-pipeline` repository is protected from being pushed to directly. Commit your code to a branch:

```sh
git checkout -b oidc-provider
git add .
git commit -m "Add OIDC provider and roles"
git push
```

This time, when you open a PR in GitHub, you should see 4 Terraform Cloud pipelines run, and all should report no changes being required. Go ahead and approve and merge the PR.
