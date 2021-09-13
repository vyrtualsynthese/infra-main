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
      version = "~> 3.58"
    }
  }
}

resource "aws_route53_zone" "ashudev" {
  name = "ashudev.com"
}

resource "aws_route53_record" "ashudev_ns" {
  allow_overwrite = true
  zone_id         = aws_route53_zone.ashudev.id
  name            = "ashudev.com"
  type            = "NS"
  ttl             = "172800"
  records = [
    "${replace(aws_route53_zone.ashudev.name_servers[0], "/\\.$/", "")}.",
    "${replace(aws_route53_zone.ashudev.name_servers[1], "/\\.$/", "")}.",
    "${replace(aws_route53_zone.ashudev.name_servers[2], "/\\.$/", "")}.",
    "${replace(aws_route53_zone.ashudev.name_servers[3], "/\\.$/", "")}.",
  ]
}

#### PRONTON MAIL ####
resource "aws_route53_record" "ashudev_mx" {
  zone_id = aws_route53_zone.ashudev.id
  name    = "ashudev.com"
  type    = "MX"
  ttl     = "3600"
  records = [
    "10 mail.protonmail.ch.",
    "20 mailsec.protonmail.ch.",
  ]
}

resource "aws_route53_record" "ashudev_txt" {
  zone_id = aws_route53_zone.ashudev.id
  name    = "ashudev.com"
  type    = "TXT"
  ttl     = "3600"
  records = [
    "protonmail-verification=99b668be7781b777d9372ac0c79ace07a86579f9",
    "v=spf1 include:_spf.protonmail.ch mx ~all",
  ]
}

resource "aws_route53_record" "protonmail_cnam_ashudev_com" {
  zone_id = aws_route53_zone.ashudev.id
  name    = "_486df7f670cbe82c7c551d7f02c26d28.ashudev.com"
  type    = "CNAME"
  ttl     = "300"
  records = [
    "_3a40174af76fa742bec7b8f7b0b8bd45.cvfdyspdbk.acm-validations.aws.",
  ]
}

resource "aws_route53_record" "dmarc_ashudev_com" {
  zone_id = aws_route53_zone.ashudev.id
  name    = "_dmarc.ashudev.com"
  type    = "TXT"
  ttl     = "3600"
  records = [
    "v=DMARC1; p=none",
  ]
}

resource "aws_route53_record" "protonmail_domainkey_ashudev_com" {
  zone_id = aws_route53_zone.ashudev.id
  name    = "protonmail._domainkey.ashudev.com"
  type    = "CNAME"
  ttl     = "3600"
  records = [
    "protonmail.domainkey.d6opq6cen37c7ogrdxtnmmxv47fpddeghacxjnx54dtrxtqifr4hq.domains.proton.ch.",
  ]
}

resource "aws_route53_record" "protonmail2_domainkey_ashudev_com" {
  zone_id = aws_route53_zone.ashudev.id
  name    = "protonmail2._domainkey.ashudev.com"
  type    = "CNAME"
  ttl     = "3600"
  records = [
    "protonmail2.domainkey.d6opq6cen37c7ogrdxtnmmxv47fpddeghacxjnx54dtrxtqifr4hq.domains.proton.ch.",
  ]
}

resource "aws_route53_record" "protonmail3_domainkey_ashudev_com" {
  zone_id = aws_route53_zone.ashudev.id
  name    = "protonmail3._domainkey.ashudev.com"
  type    = "CNAME"
  ttl     = "3600"
  records = [
    "protonmail3.domainkey.d6opq6cen37c7ogrdxtnmmxv47fpddeghacxjnx54dtrxtqifr4hq.domains.proton.ch.",
  ]
}