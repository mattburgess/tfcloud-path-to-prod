terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.49.2"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.39.0"
    }
  }

  required_version = "~> 1.6.0"
}

provider "tfe" {
  token = var.tfe_token
}

provider "github" {
  token = var.github_admin_token
}
