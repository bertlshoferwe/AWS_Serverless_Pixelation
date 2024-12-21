resource "aws_s3_bucket" "source_bucket" {
  bucket = "image-source-bucket"

  tags = {
    Name = "image-processed-bucket"
  }
}

resource "aws_s3_bucket" "processed_bucket" {
  bucket = "image-processed-bucket"

  tags = {
    Name = "image-processed-bucket"
  }
}

resource "aws_s3_bucket" "code_storage" {
  bucket = "code-storage"

  tags = {
    Name = "image-processed-bucket"
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.code_storage.id
  key    = "my_lambda_deployment"
  source = "my_lambda_deployment"
}