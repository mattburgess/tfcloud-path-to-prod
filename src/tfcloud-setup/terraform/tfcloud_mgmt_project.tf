resource "github_repository" "tfcloud_mgmt" {
  name               = "tfcloud-mgmt"
  auto_init          = true
  gitignore_template = "Terraform"
  license_template   = "mit"

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_default" "tfcloud_mgmt_main" {
  repository = github_repository.tfcloud_mgmt.name
  branch     = "main"
}

resource "github_branch_protection" "tfcloud_mgmt" {
  repository_id  = github_repository.tfcloud_mgmt.name
  pattern        = github_branch_default.tfcloud_mgmt_main.branch
  enforce_admins = true

  required_status_checks {
    strict = false
    contexts = [
      "Terraform Cloud/${tfe_organization.example.name}/${tfe_workspace.tfcloud_mgmt_prod.name}",
    ]
  }
}

resource "tfe_project" "tfcloud_mgmt" {
  organization = tfe_organization.example.id
  name         = "tfcloud-mgmt"
}

resource "tfe_workspace" "tfcloud_mgmt_prod" {
  name         = "tfcloud-mgmt-prod"
  organization = tfe_organization.example.id
  project_id   = tfe_project.tfcloud_mgmt.id

  tag_names = [
    "tfcloud-mgmt",
    "prod"
  ]

  vcs_repo {
    identifier     = github_repository.tfcloud_mgmt.full_name
    oauth_token_id = tfe_oauth_client.example_github.oauth_token_id
  }
}

resource "tfe_workspace_variable_set" "tfcloud_mgmt_prod_tfcloud_common_credentials" {
  workspace_id    = tfe_workspace.tfcloud_mgmt_prod.id
  variable_set_id = tfe_variable_set.tfcloud_common_credentials.id
}

resource "tfe_workspace_variable_set" "tfcloud_mgmt_prod_tfcloud_github_provider_credentials" {
  workspace_id    = tfe_workspace.tfcloud_mgmt_prod.id
  variable_set_id = tfe_variable_set.github_provider_credentials.id
}
