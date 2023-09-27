# VCS Workflow Integration

With the state now managed in Terraform Cloud, and the workspace configured to watch for changes in the tfcloud-mgmt repository, we're in a position to commit our code to the GitHub repository and confirm that everything's working as expected.

## Set Credentials Variables

As you'll have seen from the configuration in `tfcloud_mgmt_project.tf`, given their very sensitive nature, we deliberately keep the GitHub and Terraform Cloud API tokens out of the Terraform state; the configuration of the variables is tracked by Terraform but their values are not. For similar security reasons, our local copy of `credentials.auto.tfvars` won't be committed to the repository. So, at this point, Terraform Cloud doesn't have a copy of the API keys it needs in order to successfully interact with both Terraform Cloud itself and with GitHub.

Using the Terraform Cloud UI, update the 3 variables with the values you have stored locally in `credentials.auto.tfvars`

## Commit Code To The `tfcloud-mgmt` Repository

As the `tfcloud-mgmt-prod` workspace has been integrated with the GitHub repository, that repo is now the single source of truth for the state of your infrastructure.

If you go to the workspace in the Terraform Cloud UI, you'll notice that a run has already been triggered and that it errored with the following:

`Error: No Terraform configuration files found in working directory`

That's clear evidence that it's treating the repo as that source of truth; the repo has no code in it yet. Let's fix that:

```sh
cd ../
git clone https://github.com/your-github-org-name/tfcloud-mgmt
cd tfcloud-mgmt
cp ../tfcloud-mgmt-scratch/*.tf .
git checkout -b tfcloud-mgmt
git add .
git commit -m "Add tfcloud-mgmt resources"
git push
```

````admonish note
It's important to note that the above commit is made on a short-lived branch, rather than directly on the default (`main`) branch. The repository was specifically configured to ensure that pushes can't be made directly to the `main` branch, but first have to be validated by a Terraform Cloud [speculative plan](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans).

If you try to push directly to `main` you'll see an error similar to the following:

```
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: error: Required status check "Terraform Cloud/your-tfcloud-org/tfcloud-mgmt-prod" is expected.
To https://github.com/your-github-org/tfcloud-mgmt
 ! [remote rejected] main -> main (protected branch hook declined)
error: failed to push some refs to 'https://github.com/your-github-org/tfcloud-mgmt'
```
````

In order to have Terraform Cloud start a speculative plan, open a PR from the newly created `tfcloud-mgmt` branch.

The GitHub check should quite quickly progress from `Pending` to `All checks have passed` and the `Details` link will take you directly to the relevant run in the Terraform Cloud UI. Both the GitHub and Terraform Cloud UIs should show that no changes were detected.

Merge the PR then confirm in the Terraform Cloud UI that another plan was run which similarly detected no changes.

## Tidy up

With everything committed to the repo, we can clean up the scratch directory we were previously working from. Now would be a good opportunity to backup the various API tokens in your password manager of choice as they currently only exist in `credentials.auto.tfvars` in your local scratch directory and in Terraform Cloud as sensitive write-only variables. Once backed up, remove the scratch directory:

```sh
rm -r ../tfcloud-mgmt-scratch
```
