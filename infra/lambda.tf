resource "aws_iam_role" "scraper_role" {
  name = "scraper_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "scraper_policy" {
  name = "scraper_policy"
  role = aws_iam_role.scraper_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds-data:*",
        "lambda:InvokeFunction",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

data "archive_file" "notifier_lambda_zip" {
  type        = "zip"
  source_file = "../src/lambda/notifier/handler.go"
  output_path = "../build/lambda/notifier/notifier.zip"
}

data "archive_file" "scraper_lambda_zip" {
  type        = "zip"
  source_file = "../src/lambda/scraper/handler.go"
  output_path = "../build/lambda/scraper/scraper.zip"
}

resource "aws_lambda_function" "scraper" {
  filename      = data.archive_file.scraper_lambda_zip.output_path
  function_name = "scraper"
  role          = aws_iam_role.scraper_role.arn
  handler       = "scraper.main" # replace with your actual handler
  runtime       = "go1.x"        # replace with your actual runtime

  vpc_config {
    subnet_ids         = [aws_subnet.public.id]
    security_group_ids = [aws_security_group.security_group.id]
  }
}

resource "aws_iam_role" "notifier_role" {
  name = "notifier_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "notifier_policy" {
  name = "notifier_policy"
  role = aws_iam_role.notifier_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "notifier" {
  filename      = data.archive_file.notifier_lambda_zip.output_path
  function_name = "notifier"
  role          = aws_iam_role.notifier_role.arn
  handler       = "notifier.main" # replace with your actual handler
  runtime       = "go1.x"         # replace with your actual runtime

  vpc_config {
    subnet_ids         = [aws_subnet.public.id]
    security_group_ids = [aws_security_group.security_group.id]
  }
}