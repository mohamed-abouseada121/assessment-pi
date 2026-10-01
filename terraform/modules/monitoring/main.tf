resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-logs"
  })
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-ec2-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 CPU utilization exceeded 80% threshold"

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-cpu-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check" {
  alarm_name          = "${var.project_name}-${var.environment}-ec2-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "EC2 instance status check failed"

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-status-alarm"
  })
}
