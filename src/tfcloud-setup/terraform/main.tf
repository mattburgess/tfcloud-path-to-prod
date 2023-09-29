resource "tfe_organization" "example" {
  name  = local.tfcloud_org_name
  email = local.tfcloud_org_admin_email

  lifecycle {
    prevent_destroy = true
  }
}

resource "tfe_oauth_client" "example_github" {
  name             = "tfe-tfcloud-mgmt-github-oauth-client"
  organization     = tfe_organization.example.name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_ro_token
  service_provider = "github"
}
