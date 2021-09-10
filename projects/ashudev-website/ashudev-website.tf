terraform {

  backend "s3" {
    encrypt        = true
    bucket         = "ashudev-tf-states"
    key            = "projects/ashudev-website.tfstate"
    dynamodb_table = "tf-main-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55"
    }
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

resource "aws_s3_bucket" "ashudev-website" {
  bucket = "ashudev-website"
  acl    = "public-read"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Sid : "PublicReadGetObject",
        Effect : "Allow",
        Principal : "*",
        Action : "s3:GetObject",
        Resource : "arn:aws:s3:::ashudev-website/*"
      },
      {
        Sid : "PublicReadGetObject",
        Effect : "Allow",
        Principal : {
          "AWS" : aws_iam_user.ashudev-website-terraform.arn
        },
        Action : "s3:*",
        Resource : "arn:aws:s3:::ashudev-website/*"
      }
    ]
  })
  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = "false"
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    project = "ashudev-website"
  }
  website {
    index_document = "index.html"
  }
}

resource "aws_iam_policy" "ashudev-website" {
  name = "ashudev-website"
  path = "/projects/"
  tags = {
    "project" = "ashudev-website"
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = aws_s3_bucket.ashudev-website.arn
      },
    ]
  })
}

resource "aws_iam_user" "ashudev-website-terraform" {
  name = "ashudev-website-terraform"
  path = "/projects/ashudev-website/"
  tags = {
    project = "ashudev-website"
  }
}

/* access key not working atm
resource "aws_iam_access_key" "mailing-signature-terraform" {
  user = aws_iam_user.mailing-signature-terraform.name
}
*/

resource "aws_iam_group" "ashudev-website" {
  name = "ashudev-website"
  path = "/projects/ashudev-website/"
}

resource "aws_iam_group_membership" "ashudev-website" {
  name = "tf-ashudev-website-group-membership"
  users = [
    aws_iam_user.ashudev-website-terraform.name,
  ]

  group = aws_iam_group.ashudev-website.name
}

resource "aws_iam_group_policy_attachment" "ashudev-website" {
  group      = aws_iam_group.ashudev-website.name
  policy_arn = aws_iam_policy.ashudev-website.arn
}

resource "github_repository" "ashudev-website" {
  name                   = "ashudev-website"
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
  template {
    owner      = "vyrtualsynthese"
    repository = "nodejs-docker-typescript-boilerplate"
  }
}

resource "github_branch" "develop" {
  repository = github_repository.ashudev-website.name
  branch     = "develop"
}

/*
resource "github_actions_secret" "aws_access_key_id" {
  repository      = github_repository.mailing-signature.name
  secret_name     = "aws_access_key_id"
  plaintext_value = "aws_iam_access_key.mailing-signature-terraform.id"
}

resource "github_actions_secret" "aws_access_key_secret" {
  repository      = github_repository.mailing-signature.name
  secret_name     = "aws_access_key_secret"
  plaintext_value = "aws_iam_access_key.mailing-signature-terraform.secret"
}
*/
