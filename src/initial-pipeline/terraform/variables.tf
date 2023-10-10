variable "environment" {
  type        = string
  description = "Environment"
}

variable "oidc_provider" {
  description = "Terraform Cloud OIDC Provider details"
  type = object({
    url             = string
    site_address    = string
    client_id_list  = list(string)
    thumbprint_list = list(string)
  })
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "tfcloud_org" {
  type        = string
  description = "Terraform Cloud Organization name"
}

variable "tfcloud_project" {
  type        = string
  description = "Terraform Cloud Project names"
}

variable "workspace_name" {
  description = "Name of workspace"
  type        = string
}
