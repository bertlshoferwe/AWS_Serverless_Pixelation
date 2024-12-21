# Give EC2 ability to shut down from cli
resource "aws_iam_role" "ec2_role" {
  name = "ec2-shutdown-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ec2_stop_policy" {
  role = aws_iam_role.ec2_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["ec2:StopInstances", "ec2:DescribeInstances"],
      Effect   = "Allow",
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-shutdown-profile"
  role = aws_iam_role.ec2_role.name
}


# give lambada access
resource "aws_iam_role" "lambda_pixelator_role" { 
  name = "Lambda-pixelator"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_pixelator_policy" {  # Corrected resource name
  role       = aws_iam_role.lambda_pixelator_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}