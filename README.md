Image Pixelation with AWS Lambda
This repository contains a Lambda function that processes images uploaded to an S3 bucket by pixelating them at different resolutions. The pixelated images are then uploaded to another S3 bucket for further use.

The process is automated using AWS Lambda, S3 events, and EC2 for deploying the Lambda function, and managed with Terraform for infrastructure as code.

Overview
Image Upload: A user uploads a .jpg image to an S3 bucket (source_bucket).
Lambda Trigger: This triggers an AWS Lambda function.
Pixelation Process: The Lambda function downloads the image, pixelates it at various resolutions (8x8, 16x16, 32x32, 48x48, 64x64), and saves the processed images.
Storage: The pixelated images are uploaded to another S3 bucket (processed_bucket).
EC2 Deployment: An EC2 instance is used to install necessary dependencies and deploy the Lambda function code.
Architecture Diagram

Prerequisites
Before using this repository, ensure that you have the following set up:

AWS Account
Terraform installed
AWS CLI configured with proper access credentials
A GitHub repository for hosting the Lambda function code (optional)
Setup
1. Clone the Repository
Clone this repository to your local machine:

```bash
git clone https://github.com/username/repository.git
cd repository
```
2. Terraform Infrastructure Setup
The infrastructure for this project is managed using Terraform. The following resources are provisioned:

EC2 Instance: For running the user_data.sh script to deploy Lambda function code.
S3 Buckets: For storing the images (source and processed) and Lambda deployment package.
IAM Roles and Policies: For granting necessary permissions to Lambda and EC2 instances.
Lambda Function: To process and pixelate images.
To set up the infrastructure:

Modify the necessary variables in terraform.tfvars or directly in the Terraform configuration files.
Run the following commands to initialize, plan, and apply the Terraform configuration:
```bash
terraform init
terraform plan
terraform apply
```
3. Lambda Function Deployment
The Lambda function code is located in my_lambda_deployment.py. This code is responsible for:

Triggering when a .jpg file is uploaded to the source_bucket.
Downloading the image.
Pixelating it at multiple resolutions.
Uploading the processed images to the processed_bucket.
The user_data.sh script handles the deployment process on the EC2 instance, including downloading the necessary dependencies (such as Pillow) and uploading the packaged Lambda function to an S3 bucket (code_storage).

4. AWS Configuration
The following AWS resources are used:

S3 Buckets:
image-source-bucket: Stores the images that will be processed.
image-processed-bucket: Stores the pixelated images.
code-storage: Used to store the Lambda function deployment package.
Lambda Function:
The function is triggered by S3 events when a .jpg file is uploaded to image-source-bucket.
IAM Roles and Policies:
Lambda requires permissions to access S3 and CloudWatch for logging.
EC2 requires permissions to stop the instance after it has completed its task.
5. User Data Script
The user_data.sh script is executed when the EC2 instance starts. It performs the following:

Installs dependencies (git, awscli, wget, unzip, curl).
Clones the repository and sets up the Lambda function code.
Downloads and prepares the Pillow dependency.
Packages the Lambda function and uploads it to S3.
6. Testing the Lambda Function
After deployment:

Upload a .jpg image to image-source-bucket (you can use the AWS console or AWS CLI).
The Lambda function will be triggered automatically.
The pixelated images will be uploaded to image-processed-bucket.
7. Shutting Down the EC2 Instance
Once the EC2 instance has completed the setup and uploaded the Lambda function deployment package, it will stop itself automatically using the IAM permissions granted to it.

Example Lambda Function Code
```python
import os
import json
import uuid
import boto3
from botocore.exceptions import ClientError
from PIL import Image

processed_bucket = os.environ['processed_bucket']
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Main logic for handling the S3 event and processing the image.
    ...
```
IAM Roles and Permissions
Lambda Role (lambda_pixelator_role): Grants Lambda permissions to access S3 and CloudWatch.
EC2 Role (ec2_role): Allows EC2 to stop itself after the deployment process.
Lambda Permissions: Grants S3 permission to invoke the Lambda function on .jpg file uploads.
Troubleshooting
Common Issues
Lambda Timeout: Ensure that the Lambda function has enough time to process larger images.
Missing Permissions: Ensure that IAM roles and policies are correctly assigned.
Logs
Check the Lambda function's logs in CloudWatch for detailed error messages or debugging information.

Cleanup
To delete the infrastructure, run:

```bash
terraform destroy
```
This will remove all resources created by Terraform, including the EC2 instance, S3 buckets, Lambda function, and IAM roles.

Contributing
Feel free to fork this repository, submit issues, or create pull requests. Contributions are welcome!

License
This project is licensed under the MIT License - see the LICENSE file for details.

Make sure to replace placeholders such as https://github.com/username/repository.git with actual values specific to your project. Also, modify any details related to your infrastructure as needed.