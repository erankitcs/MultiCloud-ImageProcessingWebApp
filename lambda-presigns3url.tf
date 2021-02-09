data "archive_file" "presigneds3url_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/presigneds3url"
  output_path = "${path.module}/artifacts/presigneds3url.zip"
}

resource "aws_s3_bucket_object" "presigneds3url_artifacts" {
  bucket = aws_s3_bucket.lambda_artifacts.id
  key    = "v1.0.0/presigneds3url.zip"
  source = "${path.module}/artifacts/presigneds3url.zip"
  etag = filemd5("${path.module}/artifacts/presigneds3url.zip")
}

resource "aws_lambda_function" "presigneds3url" {
   function_name = "imagelense_presigneds3url"
   s3_bucket = aws_s3_bucket.lambda_artifacts.id
   s3_key    = "v1.0.0/presigneds3url.zip"
   handler = "main.handler"
   runtime = "nodejs12.x"

   role = aws_iam_role.presigneds3url_exec.arn
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