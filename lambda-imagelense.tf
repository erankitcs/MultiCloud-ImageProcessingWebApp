
data "archive_file" "imagelense_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/imagelense/main.js"
  output_path = "${path.module}/artifacts/imagelense.zip"
}

resource "aws_s3_bucket_object" "imagelense_artifacts" {
  bucket = aws_s3_bucket.lambda_artifacts.id
  key    = "${var.app_version}/imagelense.zip"
  source = data.archive_file.imagelense_zip.output_path 
  etag = filemd5(data.archive_file.imagelense_zip.output_path)
}

resource "aws_cloudwatch_log_group" "imagelense_log" {
  name              = "/aws/lambda/imagelense"
  retention_in_days = 7
}

resource "aws_lambda_layer_version" "imagelense_layer" {
  filename   = "lambda_functions/imagelense/lambdaLayers/ImageLense/ImageLense.zip"
  layer_name = "imagelense_layer"
  compatible_runtimes = ["nodejs12.x"]
}

resource "aws_lambda_function" "imagelense" {
   function_name = "imagelense"
   s3_bucket = aws_s3_bucket.lambda_artifacts.id
   s3_key    = aws_s3_bucket_object.imagelense_artifacts.key
   handler = "main.handler"
   runtime = "nodejs12.x"
   role = aws_iam_role.imagelense_exec.arn
   layers = [aws_lambda_layer_version.imagelense_layer.arn]
   timeout = 60
   environment {
    variables = {
      COMPUTER_VISION_SUBSCRIPTION_KEY_PS = aws_ssm_parameter.subscription_key.name
      COMPUTER_VISION_ENDPOINT            = azurerm_cognitive_account.imagelense.endpoint 
      TOPIC_ARN                           = aws_sns_topic.imagelense_data.arn
    }
  }
}

resource "aws_iam_role" "imagelense_exec" {
   name = "imagelense_lambda_role"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_lambda_permission" "imagelense_allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.imagelense.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.webapp_images.arn
}

resource "aws_s3_bucket_notification" "imagelense_bucket_notification" {
  bucket = aws_s3_bucket.webapp_images.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.imagelense.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.imagelense_allow_bucket]
}

resource "aws_iam_policy" "imagelense_logging" {
  name        = "imagelense_logging"
  path        = "/"
  description = "IAM policy for logging from a imagelense lambda."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "imagelense_logs" {
  role       = aws_iam_role.imagelense_exec.name
  policy_arn = aws_iam_policy.imagelense_logging.arn
}

#### Giving acceess to Parameter store and S3 bucket.
resource "aws_iam_policy" "imagelense_aws_access" {
  name        = "imagelense_aws_access"
  path        = "/"
  description = "IAM policy for accessing S3 bucket and Parameter store and SNS from a imagelense lambda."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GetParameter",
      "Action": [
        "ssm:GetParameter*"
      ],
      "Resource": "${aws_ssm_parameter.subscription_key.arn}",
      "Effect": "Allow"
    },
    {
      "Sid": "GetObjectsInBucket",
      "Action": [
        "s3:Get*"
      ],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.webapp_images.id}/*",
      "Effect": "Allow"
    },
    {
      "Sid": "ListObjectsInBucket",
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.webapp_images.id}",
      "Effect": "Allow"
    },
    {
            "Sid": "Allowpub",
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": ["${aws_sns_topic.imagelense_data.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "imagelense_aws_access" {
  role       = aws_iam_role.imagelense_exec.name
  policy_arn = aws_iam_policy.imagelense_aws_access.arn
}