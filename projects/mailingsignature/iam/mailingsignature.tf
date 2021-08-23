terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55"
    }
  }
}

provider "aws" {
}

resource "aws_iam_policy" "mailingsignature" {
  name        = "mailingsignature"
  path        = "/projects/"
  tags        = {
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
        Resource = "arn:aws:s3:::mailingsignature"
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
  user    = aws_iam_user.mailingsignature-terraform.name
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


# Should find a way tu push those variables to github action later
output "access" {
  value = aws_iam_access_key.mailingsignature-terraform.id
}

output "secret" {
  value = aws_iam_access_key.mailingsignature-terraform.secret
  sensitive = true
}
