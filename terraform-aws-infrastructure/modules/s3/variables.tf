variable "aws_region" {
    description = "The AWS region where resources will be created"
    type        = string
}

variable "s3_bucket_name" {
    description = "The name of the S3 bucket to store Terraform state"
    type        = string
}

variable "dynamodb_table_name" {
    description = "The name of the DynamoDB table for Terraform state locking"
    type        = string
}

variable "s3_key" {
    description = "The path to the Terraform state file in the S3 bucket"
    type        = string
}