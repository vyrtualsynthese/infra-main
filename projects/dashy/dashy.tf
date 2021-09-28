terraform {

  backend "s3" {
    encrypt        = true
    bucket         = "ashudev-tf-states"
    key            = "projects/dashy.tfstate"
    dynamodb_table = "tf-main-lock"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.13"
    }
  }
}

variable "GIT_TOKEN" {
  type = string
}

provider "github" {
  token = var.GIT_TOKEN
}

resource "github_repository" "dashy" {
  name                   = "dashy"
  visibility             = "public"
  has_issues             = false
  has_downloads          = false
  has_wiki               = false
  has_projects           = false
  allow_merge_commit     = false
  allow_squash_merge     = false
  allow_rebase_merge     = true
  delete_branch_on_merge = false
  archive_on_destroy     = true
  vulnerability_alerts   = false
  auto_init              = true
}

resource "github_branch" "develop" {
  repository = github_repository.dashy.name
  branch     = "develop"
}

resource "github_branch_protection" "main" {
  repository_id = github_repository.dashy.node_id

  pattern             = github_repository.dashy.default_branch
  enforce_admins      = true
  allows_deletions    = false
  allows_force_pushes = false
  required_status_checks {
    strict = true
  }
}

resource "github_branch_protection" "develop" {
  repository_id = github_repository.dashy.node_id

  pattern             = "develop"
  enforce_admins      = true
  allows_deletions    = false
  allows_force_pushes = true
}