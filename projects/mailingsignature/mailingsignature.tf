terraform {

  backend "s3" {
    encrypt        = true
    bucket         = "ashudev-tf-states"
    key            = "projects/mailingsignature.tfstate"
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

resource "aws_s3_bucket" "mailingsignature" {
  bucket = "mailingsignature"
  acl    = "public-read"

  policy = jsonencode({
    "Version" : "2012-10-17",

    "Statement" : [
      {
        Sid : "PublicReadGetObject",
        Effect : "Allow",
        Principal : "*",
        Action : "s3:GetObject",
        Resource : "arn:aws:s3:::mailingsignature/*"
      }
    ]
  })

  tags = {
    project = "mailingsignature"
  }
}

data "aws_s3_bucket" "mailingsignature" {
  bucket = "mailingsignature"
}

resource "aws_iam_policy" "mailingsignature" {
  name = "mailingsignature"
  path = "/projects/"

  tags = {
    "project" = "mailingsignature"
  }

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = [
          "s3:*",
        ]

        Effect   = "Allow"
        Resource = data.aws_s3_bucket.mailingsignature.arn
      },
    ]
  })
}

resource "aws_iam_user" "mailingsignature-terraform" {
  name = "mailingsignature-terraform"
  path = "/projects/mailingsignature/"

  tags = {
    project = "mailingsignature"
  }
}

resource "aws_iam_access_key" "mailingsignature-terraform" {
  user = aws_iam_user.mailingsignature-terraform.name
}

resource "aws_iam_group" "mailingsignature" {
  name = "mailingsignature"
  path = "/projects/mailingsignature/"
}

resource "aws_iam_group_membership" "mailingsignature" {
  name = "tf-mailingsignature-group-membership"

  users = [
    aws_iam_user.mailingsignature-terraform.name,
  ]

  group = aws_iam_group.mailingsignature.name
}

resource "aws_iam_group_policy_attachment" "mailingsignature" {
  group      = aws_iam_group.mailingsignature.name
  policy_arn = aws_iam_policy.mailingsignature.arn
}

data "github_repository" "mailingsignature" {
  full_name = "vyrtualsynthese/ashudevWebsite"
}

resource "github_repository_environment" "repo_environment" {
  repository  = data.github_repository.mailingsignature.name
  environment = "prod"
}

resource "github_actions_environment_secret" "aws_access_key_id" {
  repository      = data.github_repository.mailingsignature.name
  environment     = github_repository_environment.repo_environment.environment
  secret_name     = "aws_access_key_id"
  plaintext_value = "aws_iam_access_key.mailingsignature-terraform.id"
}

resource "github_actions_environment_secret" "aws_access_key_secret" {
  repository      = data.github_repository.mailingsignature.name
  environment     = github_repository_environment.repo_environment.environment
  secret_name     = "aws_access_key_secret"
  plaintext_value = "aws_iam_access_key.mailingsignature-terraform.secret"
}
