
resource "tfe_variable_set" "tfcloud_common_credentials" {
  organization = tfe_organization.example.id
  name         = "tfcloud-common-credentials"
  description  = "Common credentials required for all tfcloud projects/workspaces"
}

resource "tfe_variable" "tfcloud_common_tfe_token" {
  category        = "terraform"
  key             = "tfe_token"
  sensitive       = true
  description     = "Terraform Enterprise API Token"
  value           = "Manually set to avoid storing in TF state"
  variable_set_id = tfe_variable_set.tfcloud_common_credentials.id

  lifecycle {
    ignore_changes = [value]
  }
}

resource "tfe_variable" "tfcloud_mgmt_gh_ro_token" {
  category        = "terraform"
  key             = "github_ro_token"
  sensitive       = true
  description     = "GitHub PAT for triggering runs"
  value           = "Manually set to avoid storing in TF state"
  variable_set_id = tfe_variable_set.tfcloud_common_credentials.id

  lifecycle {
    ignore_changes = [value]
  }
}

resource "tfe_variable_set" "github_provider_credentials" {
  organization = tfe_organization.example.id
  name         = "github-admin-credentials"
  description  = "Credentials required for the GitHub Terraform provider"
}

resource "tfe_variable" "tfcloud_mgmt_gh_admin_token" {
  category        = "terraform"
  key             = "github_admin_token"
  sensitive       = true
  description     = "GitHub PAT for creating and deleting repositories"
  value           = "Manually set to avoid storing in TF state"
  variable_set_id = tfe_variable_set.github_provider_credentials.id

  lifecycle {
    ignore_changes = [value]
  }
}
