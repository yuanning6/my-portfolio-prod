import boto3
import json

def lambda_handler(event, context):
    bucket_name = 'evelyn-resume'
    object_key = 'YuanningLiu_Resume.pdf'
    
    s3_url = f"https://{bucket_name}.s3.amazonaws.com/{object_key}"

    return {
        'statusCode': 200,
        'body': json.dumps({'s3_url': s3_url})
    }
