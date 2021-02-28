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

resource "aws_s3_bucket_policy" "webapp_images_policy" {
  bucket = aws_s3_bucket.webapp_images.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "ReadPublic"
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.webapp_images.arn,
          "${aws_s3_bucket.webapp_images.arn}/*",
        ]
      },
    ]
  })
}