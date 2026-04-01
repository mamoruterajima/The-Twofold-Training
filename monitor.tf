# SNSトピックの作成
resource "aws_sns_topic" "alerts" {
  name = "system-alerts-topic"
}

# 変数（var.alert_email_address）を使って購読を設定
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email_address  # ← ここで変数を使用
}

# CloudWatchアラーム
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "ec2-cpu-high-alert"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60" # 60秒（1分）単位でチェック
  statistic           = "Average"
  threshold           = "10" # テスト用に低めの10%（後で80%に調整）
  alarm_description   = "This alarm monitors EC2 CPU utilization"

  dimensions = {
    InstanceId = aws_instance.myapp-ec2-instance.id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}