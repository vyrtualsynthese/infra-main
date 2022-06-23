terraform {

  backend "s3" {
    encrypt        = true
    bucket         = "ashudev-tf-states"
    key            = "projects/homelab.tfstate"
    dynamodb_table = "tf-main-lock"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.13"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55"
    }
  }
}

data "aws_route53_zone" "selected" {
  name         = "ashudev.com."
}

resource "aws_iam_policy" "homelab" {
  name = "homelab"
  path = "/projects/"
  tags = {
    "project" = "homelab"
  }

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
          "route53:GetChange",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource": [
          "arn:aws:route53:::hostedzone/*",
          "arn:aws:route53:::change/*"
        ]
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": "route53:ListHostedZonesByName",
        "Resource": data.aws_route53_zone.selected.arn
      }
    ]
  }
  )
}

resource "aws_iam_user" "homelab-terraform" {
  name = "homelab-terraform"
  path = "/projects/homelab/"
  tags = {
    project = "homelab"
  }
}

/* access key not working atm
resource "aws_iam_access_key" "mailing-signature-terraform" {
  user = aws_iam_user.mailing-signature-terraform.name
}
*/

resource "aws_iam_group" "homelab" {
  name = "homelab"
  path = "/projects/homelab/"
}

resource "aws_iam_group_membership" "homelab" {
  name = "tf-homelab-group-membership"
  users = [
    aws_iam_user.homelab-terraform.name,
  ]

  group = aws_iam_group.homelab.name
}

resource "aws_iam_group_policy_attachment" "homelab" {
  group      = aws_iam_group.homelab.name
  policy_arn = aws_iam_policy.homelab.arn
}

variable "GIT_TOKEN" {
  type = string
}

provider "github" {
  token = var.GIT_TOKEN
}

resource "github_repository" "homelab" {
  name                   = "homelab"
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
  repository = github_repository.homelab.name
  branch     = "develop"
}

resource "github_branch_protection" "main" {
  repository_id = github_repository.homelab.name

  pattern             = github_repository.homelab.default_branch
  enforce_admins      = true
  allows_deletions    = false
  allows_force_pushes = false
  required_status_checks {
    strict = true
  }
}

resource "github_branch_protection" "develop" {
  repository_id = github_repository.homelab.name

  pattern             = "develop"
  enforce_admins      = true
  allows_deletions    = false
  allows_force_pushes = true
}
