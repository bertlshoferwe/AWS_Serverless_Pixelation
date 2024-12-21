import os
import json
import uuid
import boto3
from botocore.exceptions import ClientError
from PIL import Image

# Bucket name for pixelated images
PROCESSED_BUCKET = os.environ['processed_bucket']
S3_CLIENT = boto3.client('s3')

def lambda_handler(event, context):
    print(event)

    # Get bucket and object key from event object
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    # Generate a unique name for the image and set temp location
    object_key = f"{uuid.uuid4()}-{key}"
    img_download_path = f"/tmp/{object_key}"
    
    try:
        # Ensure the object exists
        S3_CLIENT.head_object(Bucket=source_bucket, Key=key)
        
        # Download the source image
        with open(img_download_path, 'wb') as img_file:
            S3_CLIENT.download_fileobj(source_bucket, key, img_file)
    except ClientError as e:
        error_message = f"Error accessing file {key} in bucket {source_bucket}: {str(e)}"
        print(error_message)
        return {'statusCode': 500, 'body': json.dumps(error_message)}

    # Define pixelation sizes
    pixel_sizes = [8, 16, 32, 48, 64]
    temp_files = []

    try:
        # Pixelate and save images
        for size in pixel_sizes:
            pixelated_path = f"/tmp/pixelated-{size}x{size}-{object_key}"
            pixelate((size, size), img_download_path, pixelated_path)
            temp_files.append((pixelated_path, f"pixelated-{size}x{size}-{key}"))
    except Exception as e:
        error_message = f"Error pixelating image: {str(e)}"
        print(error_message)
        return {'statusCode': 500, 'body': json.dumps(error_message)}

    try:
        # Upload pixelated images
        for local_path, s3_key in temp_files:
            S3_CLIENT.upload_file(local_path, PROCESSED_BUCKET, s3_key)
    except ClientError as e:
        error_message = f"Error uploading pixelated images: {str(e)}"
        print(error_message)
        return {'statusCode': 500, 'body': json.dumps(error_message)}

    return {'statusCode': 200, 'body': json.dumps('Successfully processed and uploaded pixelated images.')}

def pixelate(pixelsize, image_path, pixelated_img_path):
    with Image.open(image_path) as img:
        temp_img = img.resize(pixelsize, Image.BILINEAR)
        pixelated_img = temp_img.resize(img.size, Image.NEAREST)
        pixelated_img.save(pixelated_img_path)