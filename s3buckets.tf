resource "aws_s3_bucket" "lambda_artifacts" {
  bucket_prefix = "imagelenselambdaartifacts"
  acl    = "private"
  tags = {
    Name        = "ImageLense Webapp Lambda Artifacts"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "webapp_images" {
  bucket_prefix = "imagelenseimages"
  acl    = "private"
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["POST","GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  tags = {
    Name        = "ImageLense Webapp Images"
    Environment = "Dev"
  }
}