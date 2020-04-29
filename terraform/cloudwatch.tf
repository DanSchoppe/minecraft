resource "aws_cloudwatch_metric_alarm" "inactivity" {
  alarm_name          = "minecraft-inactivity"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 5
  period              = 300
  treat_missing_data = "notBreaching"
  evaluate_low_sample_count_percentiles = "ignore"

  dimensions = {
    InstanceId = aws_instance.minecraft.id
  }

  alarm_description = "Monitors the Minecraft server for inactivity"
  alarm_actions       = ["arn:aws:automate:us-east-1:ec2:stop"]
}
