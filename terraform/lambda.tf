locals {
  lambda_source = "../lambda/handlers.js"
  lambda_build = "../lambda/build.zip"
}

data "archive_file" "init" {
  type = "zip"
  source_file = local.lambda_source
  output_path = local.lambda_build
}

resource "aws_lambda_function" "start" {
  filename = local.lambda_build
  function_name = "start"
  role = aws_iam_role.role.arn
  handler = "handlers.start"
  source_code_hash = filebase64sha256(local.lambda_build)
  runtime = "nodejs12.x"
  environment {
    variables = {
      INSTANCE_ID = aws_instance.minecraft.id
    }
  }
}

resource "aws_lambda_function" "stop" {
  filename = local.lambda_build
  function_name = "stop"
  role = aws_iam_role.role.arn
  handler = "handlers.stop"
  source_code_hash = filebase64sha256(local.lambda_build)
  runtime = "nodejs12.x"
  environment {
    variables = {
      INSTANCE_ID = aws_instance.minecraft.id
    }
  }
}

resource "aws_lambda_function" "status" {
  filename = local.lambda_build
  function_name = "status"
  role = aws_iam_role.role.arn
  handler = "handlers.status"
  source_code_hash = filebase64sha256(local.lambda_build)
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

resource "aws_iam_policy" "logging_ec2" {
  name = "lambda_logging"
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
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "${aws_instance.minecraft.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.role.name
  policy_arn = aws_iam_policy.logging_ec2.arn
}
