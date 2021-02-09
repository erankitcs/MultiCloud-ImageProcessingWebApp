resource "aws_s3_bucket" "lambda_artifacts" {
  bucket_prefix = "imagelense_webapp_lambda_artifacts"
  acl    = "private"
  tags = {
    Name        = "ImageLense Webapp Lambda Artifacts"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "webapp_images" {
  bucket_prefix = "imagelense_webapp_images"
  acl    = "private"
  tags = {
    Name        = "ImageLense Webapp Images"
    Environment = "Dev"
  }
}