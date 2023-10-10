environment = "pre-dev"

oidc_provider = {
  client_id_list = [
    "aws.workload.identity",
  ]

  site_address = "app.terraform.io"

  thumbprint_list = [
    "9e99a48a9960b14926bb7f3b02e22da2b0ab7280",
  ]

  url = "https://app.terraform.io"
}

region          = "eu-west-2"
tfcloud_org     = "your-tfcloud-org"
tfcloud_project = "tfcloud-pipeline"
