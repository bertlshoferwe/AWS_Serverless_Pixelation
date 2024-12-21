module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.0"

  function_name       = "imagePixelater"
  s3_bucket           = aws_s3_bucket.code_storage.id
  s3_existing_package = aws_s3_object.object.key
  runtime             = "python3.9"
  handler             = "lambda_function.lambda_handler"
  create_role         = false
  role                = aws_iam_role.lambda_pixelator_role.arn

  environment_variables = {
    SOURCE_BUCKET    = aws_s3_bucket.source_bucket.bucket
    PROCESSED_BUCKET = aws_s3_bucket.processed_bucket.bucket
  }
}
# Add S3 bucket notification for Lambda function
resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = aws_s3_bucket.source_bucket.id

  lambda_function {
    lambda_function_arn = module.lambda_function.this_lambda_function_arn
    events              = ["s3:ObjectCreated:*"] # Trigger on object creation events
    filter_suffix       = ".jpg"                # Only trigger for .jpg files
  }

  depends_on = [aws_lambda_permission.allow_s3_to_invoke]
}

# Grant S3 permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_to_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.this_lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source_bucket.arn
}