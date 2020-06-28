resource "aws_apigatewayv2_route" "route" {
  api_id = var.api.id
  route_key = "GET /${var.name}"
  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id = var.api.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  integration_uri = aws_lambda_function.lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_lambda_permission" "permission" {
  statement_id = "Allow${var.name}Invoke"
  action = "lambda:InvokeFunction"
  function_name = var.name
  principal = "apigateway.amazonaws.com"
  source_arn = "${var.api.execution_arn}/*/*/${var.name}"
}
