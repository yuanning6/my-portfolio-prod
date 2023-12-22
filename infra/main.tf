# Create a S3 Bucket 
resource "aws_s3_bucket" "resume_bucket" {
    bucket = "evelyn-resume"
}

resource "aws_s3_bucket_public_access_block" "public_access_to_resume_bucket" {
    bucket = aws_s3_bucket.resume_bucket.id

    block_public_acls   = false
    block_public_policy = false
}

resource "aws_s3_bucket_policy" "get_object" {
    bucket = aws_s3_bucket.resume_bucket.id
    policy = jsonencode(
        {
            Version = "2012-10-17"
            Statement = [
                {
                    Sid = "AllowPublicRead"
                    Effect = "Allow"
                    Principal = "*"
                    Action = [
                        "s3:GetObject"
                    ]
                    Resource = [
                        "arn:aws:s3:::${aws_s3_bucket.resume_bucket.id}/*"
                    ]
                }
            ]
        }
    )
}

# Upload resume to the S3 bucket 
resource "aws_s3_object" "provision_source_files" {
    bucket  = aws_s3_bucket.resume_bucket.id
    
    # Give the directory and file to be uploaded to S3
    for_each = fileset("/Users/evelynliu/Documents/Find Full Time/Software/", "YuanningLiu_Resume.pdf") 
    
    key    = each.value
    source = "/Users/evelynliu/Documents/Find Full Time/Software/${each.value}"
    content_type = each.value
}

resource "aws_lambda_function" "retrieve-resume-api" {
    filename         = data.archive_file.zip_the_python_code.output_path
    source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
    function_name    = "retrieve-resume-api"
    role             = aws_iam_role.iam_for_lambda.arn
    handler          = "retrieve_resume_func.lambda_handler"
    runtime          = "python3.12"
}

resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"

    assume_role_policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "sts:AssumeRole",
                    "Principal": {
                        "Service": "lambda.amazonaws.com"
                    },
                    "Effect": "Allow",
                    "Sid": ""
                }
            ]
        }
    )
}

resource "aws_lambda_function_url" "retrieve-resume-api-url" {
    function_name = aws_lambda_function.retrieve-resume-api.function_name
    authorization_type = "NONE"

    cors {
        allow_credentials = true
        allow_origins     = ["https://www.evelynliu.com"]
        allow_methods     = ["*"]
        allow_headers     = ["date", "keep-alive"]
        expose_headers    = ["keep-alive", "date"]
        max_age           = 86400
    }
}

data "archive_file" "zip_the_python_code" {
    type        = "zip"
    source_file = "${path.module}/lambda/retrieve_resume_func.py"
    output_path = "${path.module}/lambda/retrieve_resume_func.zip"
}