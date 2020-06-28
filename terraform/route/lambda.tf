locals {
  lambda_source = "../lambda/handlers.js"
  lambda_build = "../lambda/build.zip"
}

data "archive_file" "lambda_build" {
  type = "zip"
  source_file = local.lambda_source
  output_path = local.lambda_build
}

resource "aws_lambda_function" "lambda" {
  filename = data.archive_file.lambda_build.output_path
  function_name = var.name
  role = aws_iam_role.role.arn
  handler = "handlers.${var.name}"
  source_code_hash = data.archive_file.lambda_build.output_base64sha256
  runtime = "nodejs12.x"
  environment {
    variables = {
      INSTANCE_ID = var.ec2_instance.id
      SNS_TOPIC_ARN = var.sns_topic_arn
      SNS_MESSAGE = var.sns_message
    }
  }
}

resource "aws_iam_role" "role" {
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

# Grant logging access
resource "aws_iam_policy" "logging" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "logging_attachment" {
  role = aws_iam_role.role.name
  policy_arn = aws_iam_policy.logging.arn
}

# EC2 instance status
resource "aws_iam_policy" "status_ec2" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstanceStatus"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "status_ec2_attachment" {
  role = aws_iam_role.role.name
  policy_arn = aws_iam_policy.status_ec2.arn
}

# EC2 instance control
resource "aws_iam_policy" "control_ec2" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "${var.ec2_instance.arn}"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "control_ec2_attachment" {
  role = aws_iam_role.role.name
  policy_arn = aws_iam_policy.control_ec2.arn
}

# SNS publish
resource "aws_iam_policy" "publish_sns" {
  count = var.sns_topic_arn == null ? 0 : 1
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "SNS:Publish"
      ],
      "Resource": "${var.sns_topic_arn}"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "publish_sns_attachment" {
  count = var.sns_topic_arn == null ? 0 : 1
  role = aws_iam_role.role.name
  policy_arn = aws_iam_policy.publish_sns[count.index].arn
}
