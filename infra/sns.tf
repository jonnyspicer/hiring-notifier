resource "aws_sns_topic" "sns_topic" {
  name = "sns_topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = var.email
}