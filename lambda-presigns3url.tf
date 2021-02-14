data "archive_file" "presigneds3url_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/presigneds3url/main.js"
  output_path = "${path.module}/artifacts/presigneds3url.zip"
}

resource "aws_s3_bucket_object" "presigneds3url_artifacts" {
  bucket = aws_s3_bucket.lambda_artifacts.id
  key    = "v1.0.0/presigneds3url.zip"
  source = data.archive_file.presigneds3url_zip.output_path ##"${path.module}/artifacts/presigneds3url.zip"
  etag = filemd5(data.archive_file.presigneds3url_zip.output_path)
}

resource "aws_cloudwatch_log_group" "presigneds3url_log" {
  name              = "/aws/lambda/imagelense_presigneds3url"
  retention_in_days = 7
}

resource "aws_lambda_function" "presigneds3url" {
   function_name = "imagelense_presigneds3url"
   s3_bucket = aws_s3_bucket.lambda_artifacts.id
   s3_key    = "v1.0.0/presigneds3url.zip"
   handler = "main.handler"
   runtime = "nodejs12.x"
   role = aws_iam_role.presigneds3url_exec.arn
   environment {
    variables = {
      IMAGES_BUCKET_NAME = aws_s3_bucket.webapp_images.id
    }
  }
}

resource "aws_iam_role" "presigneds3url_exec" {
   name = "presigneds3url_lambda_role"

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

resource "aws_iam_policy" "presigneds3url_logging" {
  name        = "presigneds3url_logging"
  path        = "/"
  description = "IAM policy for logging from a presigneds3url lambda."

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

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.presigneds3url_exec.name
  policy_arn = aws_iam_policy.presigneds3url_logging.arn
}


resource "aws_iam_policy" "presigneds3url_bucketaccess" {
  name        = "presigneds3url_bucketaccess"
  path        = "/"
  description = "IAM policy for creating S3 Presigned Access."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PutObjectsInBucket",
      "Action": [
        "s3:Put*",
        "s3:*MultipartUpload*"
      ],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.webapp_images.id}/*",
      "Effect": "Allow"
    },
    {
      "Sid": "ListObjectsInBucket",
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.webapp_images.id}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_bucket_access" {
  role       = aws_iam_role.presigneds3url_exec.name
  policy_arn = aws_iam_policy.presigneds3url_bucketaccess.arn
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.presigneds3url.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.imagelenseapi.execution_arn}/*/*/*"
}