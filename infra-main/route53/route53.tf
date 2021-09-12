terraform {

  backend "s3" {
    encrypt        = true
    bucket         = "ashudev-tf-states"
    key            = "route53.tfstate"
    dynamodb_table = "tf-main-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55"
    }
  }
}

resource "aws_route53_zone" "ashudev" {
  name = "ashudev.com"
}

# TODO: NS records + SOA records