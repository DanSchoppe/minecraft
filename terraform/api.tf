resource "aws_apigatewayv2_domain_name" "domain" {
  domain_name = local.domain_name

  domain_name_configuration {
    certificate_arn = local.ssl_cert_arn
    endpoint_type = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "mapping" {
  api_id = aws_apigatewayv2_api.minecraft.id
  domain_name = aws_apigatewayv2_domain_name.domain.id
  stage = aws_apigatewayv2_stage.stage.id
}

resource "aws_apigatewayv2_api" "minecraft" {
  name = "minecraft"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.minecraft.id
  name = "$default"
  auto_deploy = true
}

module "start" {
  source = "./route"
  name = "start"
  api = aws_apigatewayv2_api.minecraft
  ec2_instance = aws_instance.minecraft
  sns_topic_arn = aws_sns_topic.server_start.arn
  sns_message = "The server has been started!"
}

module "stop" {
  source = "./route"
  name = "stop"
  api = aws_apigatewayv2_api.minecraft
  ec2_instance = aws_instance.minecraft
}

module "status" {
  source = "./route"
  name = "status"
  api = aws_apigatewayv2_api.minecraft
  ec2_instance = aws_instance.minecraft
}
