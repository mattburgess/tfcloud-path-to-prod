# Create a Module for Managing Terraform Cloud AWS-based Workspaces

As we'll be creating a number of Terraform Cloud workspaces in this section, it makes sense to create a [Terraform module](https://developer.hashicorp.com/terraform/language/modules) to ensure those workspaces are created in a consistent manner. Our module will follow the [standard module structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure), which defines the layout of modules and their position in the filesystem relative to other code.

To start with, we'll need to declare a number of variables that will be passed to the module. Copy and paste the following into `modules/tfcloud_aws_workspace/variables.tf`:

```hcl
{{#include terraform/modules/tfcloud_aws_workspace/variables.tf}}
```

Next, we'll have the module manage some Terraform Cloud resources. Copy and paste the following into `modules/tfcloud_aws_workspace/main.tf`:

```hcl
{{#include terraform/modules/tfcloud_aws_workspace/main.tf}}
```

As you can see, the module is relatively simple; it simply creates a Terraform Cloud Workspace and some workspace-specific variables. As this guide is opinionated, we know that we'll be asking Terraform Cloud to create resources in an AWS account and we'd like it to use an OIDC provider in order to avoid using static authentication credentials. The workspace-specific variables help support that authentication flow:

* `region` - as we've configured our workspaces to be region-specific, as per Hashicorp's [examples](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/creating#workspace-naming), and the AWS provider needs to know what region to operate in, we store this as a Terraform variable.

* `TFC_AWS_PLAN_ROLE_ARN` and `TFC_AWS_APPLY_ROLE_ARN` environment variables. These are part of the OIDC authentication flow; Terraform Cloud will assume these roles when running plan and apply operations respectively. We will create these roles shortly.

The OIDC setup is described in detail in [Terraform Cloud's documentation](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration).

Finally, we'll want to output the workspaces that the module creates as these will be used when configuring GitHub Pull Request checks a little later on. Copy and paste the following into `modules/tfcloud_aws_workspace/outputs.tf`:

```hcl
{{#include terraform/modules/tfcloud_aws_workspace/outputs.tf}}
```

With the module in place, the next section will make use of it to actually create our example pipeline.
