resource "aws_cloudwatch_metric_alarm" "inactivity" {
  alarm_name = "minecraft-inactivity"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 3
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  statistic = "Average"
  threshold = 2
  period = 300
  treat_missing_data = "breaching"

  dimensions = {
    InstanceId = aws_instance.minecraft.id
  }

  alarm_description = "Monitors the Minecraft server for inactivity"
  alarm_actions = ["arn:aws:automate:us-east-1:ec2:stop"]
}
