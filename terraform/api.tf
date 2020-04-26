resource "aws_apigatewayv2_api" "minecraft" {
  name = "minecraft"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.minecraft.id
  name   = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "start" {
  api_id = aws_apigatewayv2_api.minecraft.id
  route_key = "GET /start"
  target = "integrations/${aws_apigatewayv2_integration.start.id}"
}

resource "aws_apigatewayv2_integration" "start" {
  api_id = aws_apigatewayv2_api.minecraft.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  integration_uri = aws_lambda_function.start.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_lambda_permission" "start_permission" {
  statement_id  = "AllowStartInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "start"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.minecraft.execution_arn}/*/*/start"
}

resource "aws_apigatewayv2_route" "stop" {
  api_id = aws_apigatewayv2_api.minecraft.id
  route_key = "GET /stop"
  target = "integrations/${aws_apigatewayv2_integration.stop.id}"
}

resource "aws_apigatewayv2_integration" "stop" {
  api_id = aws_apigatewayv2_api.minecraft.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  integration_uri = aws_lambda_function.stop.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_lambda_permission" "stop_permission" {
  statement_id  = "AllowStopInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "stop"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.minecraft.execution_arn}/*/*/stop"
}
