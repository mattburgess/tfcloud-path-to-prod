variable "apply_role_arns" {
  description = "List of role ARNs to the workspace's apply policy"
  type        = list(string)
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "oidc_provider_url" {
  description = "Terraform Cloud OIDC Provider URL"
  type        = string
  default     = "https://app.terraform.io"
}

variable "plan_role_arns" {
  description = "List of role ARNs to the workspace's plan policy"
  type        = list(string)
}

variable "tfcloud_org" {
  description = "Terraform Cloud Organization name"
  type        = string
}

variable "tfcloud_project" {
  description = "Terraform Cloud project name"
  type        = string
}

variable "workspace_name" {
  description = "Terraform Cloud workspace name"
  type        = string
}
