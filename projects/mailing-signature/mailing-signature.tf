terraform {

  backend "s3" {
    encrypt        = true
    bucket         = "ashudev-tf-states"
    key            = "projects/mailing-signature.tfstate"
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

resource "aws_s3_bucket" "mailing-signature" {
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
    project = "mailing-signature"
  }
}

resource "aws_iam_policy" "mailing-signature" {
  name = "mailing-signature"
  path = "/projects/"
  tags = {
    "project" = "mailing-signature"
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = aws_s3_bucket.mailing-signature.arn
      },
    ]
  })
}

resource "aws_iam_user" "mailing-signature-terraform" {
  name = "mailing-signature-terraform"
  path = "/projects/mailing-signature/"
  tags = {
    project = "mailing-signature"
  }
}

resource "aws_iam_access_key" "mailing-signature-terraform" {
  user = aws_iam_user.mailing-signature-terraform.name
}

resource "aws_iam_group" "mailing-signature" {
  name = "mailing-signature"
  path = "/projects/mailing-signature/"
}

resource "aws_iam_group_membership" "mailing-signature" {
  name = "tf-mailing-signature-group-membership"
  users = [
    aws_iam_user.mailing-signature-terraform.name,
  ]

  group = aws_iam_group.mailing-signature.name
}

resource "aws_iam_group_policy_attachment" "mailing-signature" {
  group      = aws_iam_group.mailing-signature.name
  policy_arn = aws_iam_policy.mailing-signature.arn
}

/*data "github_repository" "mailing-signature" {
  full_name = "vyrtualsynthese/ashudevWebsite"
}

resource "github_repository_environment" "repo_environment" {
  repository  = data.github_repository.mailing-signature.name
  environment = "prod"
}

resource "github_actions_environment_secret" "aws_access_key_id" {
  repository      = data.github_repository.mailing-signature.name
  environment     = github_repository_environment.repo_environment.environment
  secret_name     = "aws_access_key_id"
  plaintext_value = "aws_iam_access_key.mailing-signature-terraform.id"
}

resource "github_actions_environment_secret" "aws_access_key_secret" {
  repository      = data.github_repository.mailing-signature.name
  environment     = github_repository_environment.repo_environment.environment
  secret_name     = "aws_access_key_secret"
  plaintext_value = "aws_iam_access_key.mailing-signature-terraform.secret"
}*/
