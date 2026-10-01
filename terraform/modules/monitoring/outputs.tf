output "log_group_name" {
  value = aws_cloudwatch_log_group.app.name
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.app.arn
}

output "cpu_alarm_name" {
  value = aws_cloudwatch_metric_alarm.ec2_cpu_high.alarm_name
}
