terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.48.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.38.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.19.0"
    }
  }
}

provider "tfe" {
  token = var.tfe_token
}

provider "github" {
  token = var.github_admin_token
}

provider "aws" {
  region = "us-east-1"
}
