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

provider "aws" {
  region = "eu-west-3"
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}

resource "aws_acm_certificate" "ashudev" {
  provider          = aws.us
  domain_name       = "ashudev.com"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}

data "aws_cloudfront_cache_policy" "caching-optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_route53_zone" "ashudev-zones" {
  name = "ashudev.com"
}

resource "aws_cloudfront_distribution" "ashudev" {
  enabled             = true
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  origin {
    domain_name         = aws_s3_bucket.ashudev-website.bucket_regional_domain_name
    origin_id           = "ashudev-bucket"
    connection_attempts = "3"
    connection_timeout  = "10"
    origin_shield {
      enabled              = true
      origin_shield_region = "eu-central-1"
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  price_class = "PriceClass_All"
  aliases     = ["ashudev.com"]
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "ashudev-bucket"
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching-optimized.id
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.ashudev.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_route53_record" "ashudev_a" {
  zone_id = data.aws_route53_zone.ashudev-zones.id
  name    = "ashudev.com"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.ashudev.domain_name
    zone_id                = aws_cloudfront_distribution.ashudev.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ashudev_aaaa" {
  zone_id = data.aws_route53_zone.ashudev-zones.id
  name    = "ashudev.com"
  type    = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.ashudev.domain_name
    zone_id                = aws_cloudfront_distribution.ashudev.hosted_zone_id
    evaluate_target_health = false
  }
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

resource "github_branch_protection" "main" {
  repository_id = github_repository.ashudev-website.node_id

  pattern             = github_repository.ashudev-website.default_branch
  enforce_admins      = true
  allows_deletions    = false
  allows_force_pushes = false
  required_status_checks {
    strict = true
  }
}

resource "github_branch_protection" "develop" {
  repository_id = github_repository.ashudev-website.node_id

  pattern             = "develop"
  enforce_admins      = true
  allows_deletions    = false
  allows_force_pushes = true
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
