variable "pipeline_environment_name" {
  description = "Name of the pipeline environment being configured"
  type        = string
}

variable "pipeline_environment_configuration" {
  description = "Configures which AWS accounts and regions each pipeline stage will be deployed to"
  type = object({
    aws_account_id = string,
    regions        = list(string),
  })
}

variable "tfe_project" {
  description = "Details of the Terraform Cloud project that the workspace belongs to"
  type = object({
    tfe_organization = string
    project_name     = string
    project_id       = string
  })
}

variable "vcs_repo_name" {
  description = "Name of the VCS repo to link all workspaces to"
  type        = string
}

variable "vcs_repo_oauth_client_token_id" {
  description = "Oauth token used to authentication workspaces with the VCS provider"
  type        = string
}
