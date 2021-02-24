resource "aws_sns_topic" "imagelense_data" {
  name = "imagelense-data-topic"
}

## Subscript SNS topic
resource "aws_sns_topic_subscription" "imagelense_data_sub" {
  topic_arn = aws_sns_topic.imagelense_data.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.load_firebase.arn
}