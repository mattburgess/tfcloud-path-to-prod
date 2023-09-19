# Pre-Requisites

A number of accounts, credentials and command line utilities are required in order to follow this guide.

## Accounts

1. An account on [HashiCorp Cloud Platform (HCP)](https://portal.cloud.hashicorp.com/sign-up)

1. An account on Terraform Cloud; visit [Terraform Cloud](https://app.terraform.io) and click `Continue with HCP Account`

1. An account on [GitHub](https://github.com/signup)

## Command Line Utilities

1. The `terraform` CLI. Follow Hashicorp's [Installation instructions](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) for your OS of choice. Although you'll be using Terraform Cloud to ultimately deploy your infrastructure, the local CLI is used to initially bootstrap things and can be further used to execute plans and applies in Terraform Cloud

## Terraform Code Working Directory

We'll need a directory to work from which will contain our initial Terraform code that will create the Terraform Cloud resources and GitHub repository. The rest of the instructions in this chapter assume you're in the top level of that directory:

```sh
mkdir tfcloud-mgmt-scratch
cd tfcloud-mgmt-scratch
```

## Terraform Cloud API Key

In order for the `terraform` CLI - both your local binary and that on the Terraform Cloud servers - to interact with Terraform Cloud, you need to generate an authorization token, otherwise known as an API key.

Create the API key:

```sh
terraform login
```

```admonish note
This is only required the first time you need to create an API key. The `login` command will create a credentials file (`credentials.tfrc.json`) which will be used by your local `terraform` CLI.
```

Create a file called `credentials.auto.tfvars` using the following command:

```sh
tfe_token=$(jq -r '.credentials."app.terraform.io".token' ~/.terraform.d/credentials.tfrc.json)
echo "tfe_token = \"${tfe_token}\"" > credentials.auto.tfvars
```

```admonish note
The default `.gitignore` file that was added to the repo during initial creation will prevent this `credentials.auto.tfvars` file from being committed; this is exactly what we want as it contains security-critical information that you absolutely **do not** want made public on GitHub.
```

## GitHub Personal Access Token for Pipelines

Similar to the Terraform Cloud API key created above, because Terraform will be interacting with GitHub to detect code changes then it needs an authorization token.

GitHub's [documentation](https://docs.github.com/en/enterprise-server@3.6/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) shows how to create a PAT.

Applying the principle of least privilege, the PAT token only needs read access to repositories. This enables Terraform Cloud to detect commits pushed to repositories and subsequently run plans and applies based on those changes. To grant this access select `Repository access -> All repositories` then under `Permissions -> Repository permissions` select `Contents -> Read-only`. Terraform Cloud also needs to be able to create webhooks. To grant this access
select `Permissions -> Repository permissions -> Webhooks -> Read and Write`

Set the appropriate credentials variable:

```sh
echo 'github_ro_token = "github_pat_*****..."' >> credentials.auto.tfvars
```

```admonish tip
The GitHub PAT above has access to **all** repositories; this is done on the assumption that there will be several repositories containing Terraform code. It also reduces friction if a team creates new repositories that contain Terraform code as a new PAT won't need to be generated to grant access to them. Your security posture may be different though, so you may need to create a PAT with access to only specific repositories.
```

## GitHub Personal Access Token for Repository Management

The [Terraform Provider for GitHub](https://github.com/integrations/terraform-provider-github) is used to enable Terraform to create GitHub repositories and manage their settings. Because of these administrative type functions, it requires a PAT with much higher privilege than the PAT created above.

To grant this access select `Repository access -> All repositories` then under `Permissions -> Repository permissions` select `Administration -> Read and write`. The provider also needs write access to the contents of repositories in order to manage certain settings. To grant this access
select `Permissions -> Repository permissions -> Contents -> Read and write`

Set the appropriate credentials variable:

```sh
echo 'github_admin_token = "github_pat_*****..."' >> credentials.auto.tfvars
```

```admonish warning
The GitHub PAT above has **very** high privilges across **all** repositories. As such, it is crucial that this PAT isn't leaked or re-used for other purposes.
```

## Terraform Cloud and GitHub Related Settings

Copy and paste the following into a new file, `locals.tf`, and adjust the values to match your desired Terraform Cloud and GitHub organization names:

```hcl
{{#include locals.tf}}
```
