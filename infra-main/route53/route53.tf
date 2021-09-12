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

resource "aws_route53_record" "ashudev_ns" {
  allow_overwrite = true
  zone_id = aws_route53_zone.ashudev.id
  name    = "ashudev.com"
  type    = "NS"
  ttl = "172800"
  records = [
    "${replace(aws_route53_zone.ashudev.name_servers[0], "/\\.$/", "")}.",
    "${replace(aws_route53_zone.ashudev.name_servers[1], "/\\.$/", "")}.",
    "${replace(aws_route53_zone.ashudev.name_servers[2], "/\\.$/", "")}.",
    "${replace(aws_route53_zone.ashudev.name_servers[3], "/\\.$/", "")}.",
  ]
}