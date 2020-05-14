locals {
  lambda_source = "../lambda/handlers.js"
  lambda_build = "../lambda/build.zip"
}

data "archive_file" "lambda_build" {
  type = "zip"
  source_file = local.lambda_source
  output_path = local.lambda_build
}

resource "aws_lambda_function" "start" {
  filename = data.archive_file.lambda_build.output_path
  function_name = "start"
  role = aws_iam_role.role.arn
  handler = "handlers.start"
  source_code_hash = data.archive_file.lambda_build.output_base64sha256
  runtime = "nodejs12.x"
  environment {
    variables = {
      INSTANCE_ID = aws_instance.minecraft.id
    }
  }
}

resource "aws_lambda_function" "stop" {
  filename = data.archive_file.lambda_build.output_path
  function_name = "stop"
  role = aws_iam_role.role.arn
  handler = "handlers.stop"
  source_code_hash = data.archive_file.lambda_build.output_base64sha256
  runtime = "nodejs12.x"
  environment {
    variables = {
      INSTANCE_ID = aws_instance.minecraft.id
    }
  }
}

resource "aws_lambda_function" "status" {
  filename = data.archive_file.lambda_build.output_path
  function_name = "status"
  role = aws_iam_role.role.arn
  handler = "handlers.status"
  source_code_hash = data.archive_file.lambda_build.output_base64sha256
  runtime = "nodejs12.x"
  environment {
    variables = {
      INSTANCE_ID = aws_instance.minecraft.id
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
  name = "LambdaLogging"
  description = "IAM policy for logging from a lambda"

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

# Grant EC2 instance status
resource "aws_iam_policy" "status_ec2" {
  name = "LambdaEC2Status"
  description = "IAM policy for logging from a lambda"

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

# Grant EC2 instance control
resource "aws_iam_policy" "control_ec2" {
  name = "MinecraftControl"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstanceStatus",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "${aws_instance.minecraft.arn}"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "control_ec2_attachment" {
  role = aws_iam_role.role.name
  policy_arn = aws_iam_policy.control_ec2.arn
}
