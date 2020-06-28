resource "aws_sns_topic" "server_start" {
  name = "start"
}

# Example subscription:
# resource "aws_sns_topic_subscription" "server_start_subscription" {
#   topic_arn = aws_sns_topic.server_start.arn
#   protocol = "sms"
#   endpoint = "+16125555555"
# }
