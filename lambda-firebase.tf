data "archive_file" "load_firebase_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/load_firebase/main/"
  output_path = "${path.module}/artifacts/load_firebase.zip"
}

resource "aws_s3_bucket_object" "load_firebase_artifacts" {
  bucket = aws_s3_bucket.lambda_artifacts.id
  key    = "${var.app_version}/load_firebase.zip"
  source = data.archive_file.load_firebase_zip.output_path
  etag = filemd5(data.archive_file.load_firebase_zip.output_path)
}

resource "aws_cloudwatch_log_group" "load_firebase_log" {
  name              = "/aws/lambda/imagelense_load_firebase"
  retention_in_days = 7
}

resource "aws_lambda_layer_version" "firebase_layer" {
  filename   = "lambda_functions/load_firebase/lambdalayers/loadFirebase.zip"
  layer_name = "firebase_layer"
  compatible_runtimes = ["nodejs12.x"]
}

resource "aws_lambda_function" "load_firebase" {
   function_name = "imagelense_load_firebase"
   s3_bucket = aws_s3_bucket.lambda_artifacts.id
   s3_key    = aws_s3_bucket_object.load_firebase_artifacts.key
   handler = "main.handler"
   runtime = "nodejs12.x"
   role = aws_iam_role.load_firebase_exec.arn
   layers = [aws_lambda_layer_version.firebase_layer.arn]
   timeout = 60
}

resource "aws_iam_role" "load_firebase_exec" {
   name = "load_firebase_lambda_role"

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

resource "aws_iam_policy" "load_firebase_logging" {
  name        = "load_firebase_logging"
  path        = "/"
  description = "IAM policy for logging from a load_firebase lambda."

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

resource "aws_iam_role_policy_attachment" "load_firebase_logs" {
  role       = aws_iam_role.load_firebase_exec.name
  policy_arn = aws_iam_policy.load_firebase_logging.arn
}

## Allowing execution from SNS.
resource "aws_lambda_permission" "imagelense_data_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.load_firebase.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.imagelense_data.arn
}