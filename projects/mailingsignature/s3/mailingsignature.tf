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

resource "aws_s3_bucket" "mailingsignature" {
  bucket      = "mailingsignature"
  acl         = "public-read"

  policy      = jsonencode({
    "Version": "2012-10-17",

    "Statement": [
      {
        Sid: "PublicReadGetObject",
        Effect: "Allow",
        Principal: "*",
        Action: "s3:GetObject",
        Resource: "arn:aws:s3:::mailingsignature/*"
      }
    ]
  })

  tags = {
    project = "mailingsignature"
  }
}
