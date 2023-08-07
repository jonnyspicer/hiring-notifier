resource "aws_sns_topic" "sns_topic" {
  name = "new_job_notifications"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = var.email
}

resource "aws_vpc_endpoint" "sns" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.sns"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.security_group.id, aws_vpc.main.default_security_group_id]
  subnet_ids         = [aws_subnet.public.id, aws_subnet.private.id]

  private_dns_enabled = true
}