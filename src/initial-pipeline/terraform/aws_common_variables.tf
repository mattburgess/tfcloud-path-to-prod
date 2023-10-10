resource "tfe_variable_set" "aws_common" {
  name         = "aws-common"
  description  = "Variables common to all projects that use the AWS provider"
  organization = tfe_organization.example.id
}

resource "tfe_variable" "aws_common_oidc_provider" {
  key             = "oidc_provider"
  value           = <<-EOT
  {
    url             = "https://app.terraform.io"
    site_address    = "app.terraform.io"
    client_id_list  = [
    "aws.workload.identity",
    ]
    thumbprint_list = [
      "9e99a48a9960b14926bb7f3b02e22da2b0ab7280",
    ]
  }
  EOT
  hcl             = true
  category        = "terraform"
  description     = "Terraform Cloud OIDC Provider details"
  variable_set_id = tfe_variable_set.aws_common.id
}

resource "tfe_variable" "aws_common_tfcloud_org" {
  key             = "tfcloud_org"
  value           = tfe_organization.example.name
  category        = "terraform"
  description     = "Name of the Terraform Cloud Organization"
  variable_set_id = tfe_variable_set.aws_common.id
}

resource "tfe_variable" "aws_common_provider_auth" {
  category        = "env"
  key             = "TFC_AWS_PROVIDER_AUTH"
  value           = "true"
  description     = "Tells Terraform Cloud to authenticate to AWS"
  variable_set_id = tfe_variable_set.aws_common.id
}
