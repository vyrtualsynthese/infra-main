resource "aws_iam_policy" "policy" {
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
        Resource = "*"
        Condition : {
          "StringEquals" : {
            "s3:ResourceTag/project": "mailingsignature"
          }
        }
      },
    ]
  })
}
