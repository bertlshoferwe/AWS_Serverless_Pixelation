#!/bin/bash

# Install needed dependencys
sudo yum update -y
sudo yum install -y git awscli wget unzip curl

# Setting variables for ec2
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

# Create directories
mkdir lambda

# Clone the GitHub repository copy needed files to lambda directory
git clone https://github.com/username/repository.git /home/ec2-user/repository
cp /image-pixelation/my_lambda_deployment.py /lambda

# Obtain dependecies needed for lambda function function
cd lambda
wget https://files.pythonhosted.org/packages/f3/3b/d7bb231b3bc1414252e77463dc63554c1aeccffe0798524467aca7bad089/Pillow-9.0.1-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
unzip Pillow-9.0.1-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
rm Pillow-9.0.1-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
zip -r ../my-deployment-package.zip .
aws s3 cp my-deployment-package.zip s3://code_storage

# Shut down instance as no longer needed
aws ec2 stop-instances --instance-ids $INSTANCE_ID --region $REGION