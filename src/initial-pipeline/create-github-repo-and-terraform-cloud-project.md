# Create GitHub Repo and Terraform Cloud Project

Copy and paste the following into a new file, `tfcloud_pipeline_project.tf` in the `tfcloud-mgmt` repo.

```hcl
{{#include terraform/tfcloud_pipeline_project.tf}}
```

Adjust the `aws_account_id` values to match your AWS account setup. Whilst the pre-requisites only strictly need us to have a single AWS account, it's strongly recommended to maintain separate accounts for your different path to production environments. AWS has some [guidance](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/core-concepts.html) on this topic if you wish to explore it further but the main reasons for account separation are:

* Minimises the "blast radius" of changes; if your production account is the only one that contains production resources, then a change to your dev account can't possibly affect your production service.
* Some AWS services, most notably IAM and Route53 are global in nature. For example, a change to an IAM role in an account shared between environments will affect all environments at the same time.

One option to avoid some of the IAM-related problems that can arise from having a shared account is to prefix or suffix the role name such that unique roles are created in each workspace. This is alluded to above, and more clearly shown in the next section when we create the roles necessary for OIDC authentication.

The code above creates 4 workspaces, each one representing a separate stage in the path to production.

Commit and push your changes to a branch, and raise a PR. The resulting Terraform Cloud plan should show 35 resources will be created. Go ahead and merge the PR, then apply the changes.

If you take a look at the new `tfcloud-pipeline` project in the Terraform Cloud UI, you'll see that it has the expected 4 workspaces configured and that each of them had a plan triggered by the initial commit to the new `tfcloud-pipeline` GitHub repo. Again, as expected at this stage, all of those runs failed due to a lack of Terraform code in the repository. The next section will bootstrap the OIDC authentication between Terraform Cloud and your AWS account so that Terraform Cloud can plan and apply changes successfully.
