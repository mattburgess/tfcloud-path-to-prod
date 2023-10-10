locals {
  tfcloud_pipeline_project_name = "tfcloud-pipeline"

  tfcloud_pipeline_environment_configuration = {

    "pre-dev" = {
      aws_account_id = "320797911953"
      regions = [
        "eu-west-2"
      ]
    },

    "dev" = {
      aws_account_id = "320797911953"
      regions = [
        "eu-west-2",
      ]
    },

    "test" = {
      aws_account_id = "320797911953"
      regions = [
        "eu-west-2",
      ]
    },

    "prod" = {
      aws_account_id = "320797911953"
      regions = [
        "eu-west-2",
      ]
    },
  }

  tfcloud_pipeline_workspace_names = flatten([for k, v in local.tfcloud_pipeline_environment_configuration : module.tfcloud_pipeline_workspaces[k].workspace_names])
}

resource "github_repository" "tfcloud_pipeline" {
  name               = local.tfcloud_pipeline_project_name
  auto_init          = true
  gitignore_template = "Terraform"
  license_template   = "mit"

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_default" "tfcloud_pipeline_main" {
  repository = github_repository.tfcloud_pipeline.name
  branch     = "main"
}

resource "github_branch_protection" "tfcloud_pipeline_main" {
  repository_id  = github_repository.tfcloud_pipeline.name
  pattern        = github_branch_default.tfcloud_pipeline_main.branch
  enforce_admins = true

  required_status_checks {
    strict   = false
    contexts = formatlist("Terraform Cloud/%s/%s", tfe_organization.example.name, local.tfcloud_pipeline_workspace_names)
  }
}

resource "tfe_project" "tfcloud_pipeline" {
  organization = tfe_organization.example.id
  name         = local.tfcloud_pipeline_project_name
}

resource "tfe_project_variable_set" "tfcloud_pipeline_aws_common" {
  project_id      = tfe_project.tfcloud_pipeline.id
  variable_set_id = tfe_variable_set.aws_common.id
}

resource "tfe_variable_set" "tfcloud_pipeline_common" {
  name         = "${local.tfcloud_pipeline_project_name}-common"
  description  = "Variables common to all workspaces within the ${local.tfcloud_pipeline_project_name} project"
  organization = tfe_organization.example.id
}

resource "tfe_variable" "tfcloud_pipeline_common_tfcloud_project" {
  category        = "terraform"
  key             = "tfcloud_project"
  value           = local.tfcloud_pipeline_project_name
  description     = "Name of the Terraform Cloud Project"
  variable_set_id = tfe_variable_set.tfcloud_pipeline_common.id
}

resource "tfe_project_variable_set" "tfcloud_pipeline_common" {
  project_id      = tfe_project.tfcloud_pipeline.id
  variable_set_id = tfe_variable_set.tfcloud_pipeline_common.id
}

module "tfcloud_pipeline_workspaces" {
  for_each = local.tfcloud_pipeline_environment_configuration
  source   = "./modules/tfcloud_aws_workspace"

  tfe_project = {
    tfe_organization = tfe_project.tfcloud_pipeline.organization
    project_name     = tfe_project.tfcloud_pipeline.name
    project_id       = tfe_project.tfcloud_pipeline.id
  }

  pipeline_environment_name          = each.key
  pipeline_environment_configuration = each.value
  vcs_repo_name                      = github_repository.tfcloud_pipeline.full_name
  vcs_repo_oauth_client_token_id     = tfe_oauth_client.example_github.oauth_token_id
}

resource "tfe_run_trigger" "tfcloud_pipeline_dev_eu_west_2" {
  workspace_id  = module.tfcloud_pipeline_workspaces["dev"].workspace_ids["tfcloud-pipeline-dev-eu-west-2"]
  sourceable_id = module.tfcloud_pipeline_workspaces["pre-dev"].workspace_ids["tfcloud-pipeline-pre-dev-eu-west-2"]
}

resource "tfe_run_trigger" "tfcloud_pipeline_test_eu_west_2" {
  workspace_id  = module.tfcloud_pipeline_workspaces["test"].workspace_ids["tfcloud-pipeline-test-eu-west-2"]
  sourceable_id = module.tfcloud_pipeline_workspaces["dev"].workspace_ids["tfcloud-pipeline-dev-eu-west-2"]
}

resource "tfe_run_trigger" "tfcloud_pipeline_prod_eu_west_2" {
  workspace_id  = module.tfcloud_pipeline_workspaces["prod"].workspace_ids["tfcloud-pipeline-prod-eu-west-2"]
  sourceable_id = module.tfcloud_pipeline_workspaces["test"].workspace_ids["tfcloud-pipeline-test-eu-west-2"]
}
