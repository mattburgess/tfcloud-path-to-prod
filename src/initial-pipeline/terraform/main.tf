locals {
  configure_oidc = var.environment == "pre-dev" && var.region == "eu-west-2"
}

resource "aws_iam_openid_connect_provider" "terraform_cloud" {
  count           = local.configure_oidc ? 1 : 0
  url             = var.oidc_provider.url
  client_id_list  = var.oidc_provider.client_id_list
  thumbprint_list = var.oidc_provider.thumbprint_list
}

module "tfcloud_pipeline_roles" {
  source          = "./modules/tfcloud_role"
  environment     = var.environment
  tfcloud_project = var.tfcloud_project
  tfcloud_org     = var.tfcloud_org
  workspace_name  = var.workspace_name

  plan_role_arns = [
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess",
  ]

  apply_role_arns = [
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
  ]
}
