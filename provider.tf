terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.60.0"
    }
  }
  # must setup S3 bucket and DynamoDB before uncommenting the code below
  /* backend "s3" {
    bucket         = "tfremotestate-1234"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfremotestatelock-1234"
    encrypt        = true
  } */
}


#use code below to setup S3 and Dynamodb for remote state
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "tfremotestate-1234"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
    Name    = "Terraform Remote State Bucket"
  }
}

module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = "tfremotestatelock-1234"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  tags = {
    Terraform = "true"
    Name      = "Terraform Lock Table"
  }
}