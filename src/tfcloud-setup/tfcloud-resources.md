# Create Terraform Cloud Resources

We'd like Terraform to deploy the Terraform Cloud organization, a project within that organization, and a workspace within that project. Further, by linking the GitHub repository with the workspace, we can demonstrate Terraform Cloud's ability to automatically plan and apply changes made by commits to that repository.

To start with, copy and paste the following into `organization.tf` to create the Terraform Cloud Organization, replacing the placeholder values with ones that will work for you. This will also create an OAuth client so that Terraform can watch for and react to commits to GitHub repositories.

```hcl
{{#include organization.tf}}
```

Next, copy and paste the following into `tfcloud_variables.tf`. The resources below manage common variable sets that hold the various credentials needed for both Terraform Cloud and the GitHub Terraform provider to interact with their respective APIs:

```hcl
{{#include tfcloud_variables.tf}}
```

Next, copy and paste the following into `tfcloud_mgmt_project.tf` to create the Terraform Cloud project and workspace along with the associated GitHub repository. This also creates a workspace-scoped "variable set" resource to hold the credentials that Terraform Cloud will need in order to interact with both the Terraform Enterprise API and GitHub API. We follow Hashicorp's [recommended practice](https://developer.hashicorp.com/terraform/tutorials/cloud/cloud-multiple-variable-sets) of scoping the variable sets as narrowly as possible; we don't want any old project or workspace in our organization to be able to make changes to the Terraform Cloud organization.

```hcl
{{#include tfcloud_mgmt_project.tf}}
```

Running `terraform apply` should show that 14 resources need to be created, so go ahead and confirm to get things set up!

```sh
$ terraform apply
...
Plan: 14 to add, 0 to change, 0 to destroy.
...
Apply complete! Resources: 14 added, 0 changed, 0 destroyed.
```

Congratulations! You now have a Terraform Cloud organization, project and workspace configured. You also have a GitHub repository that is linked up to that workspace.

Notice that in your current working directory there is a file called `terraform.tfstate` which holds the state of your Terraform Cloud configuration as far as your local `terraform` considers it. Alas, Terraform Cloud itself knows nothing of this state of affairs. Next we'll perform a state migration which is how we get your local copy of the state into Terraform Cloud.
