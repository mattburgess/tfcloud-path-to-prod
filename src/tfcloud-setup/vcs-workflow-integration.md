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
cp ../tfcloud-mgmt-scratch/*.tf
git add .
git commit -m "Add tfcloud-mgmt resources"
git push
```

Visiting the workspace in the Terraform Cloud UI, you should see a run be queued then the plan running. It should finish with no changes being detected. This now proves that the state, as managed by Terraform Cloud, is up to date with the code in the GitHub repository.

## Tidy up

With everything committed to the repo, we can clean up the scratch directory we were previously working from. Now would be a good opportunity to backup the various API tokens in your password manager of choice as they currently only exist in `credentials.auto.tfvars` in your local scratch directory and in Terraform Cloud as sensitive write-only variables. Once backed up, remove the scratch directory:

```sh
rm -r ../tfcloud-mgmt-scratch
```
