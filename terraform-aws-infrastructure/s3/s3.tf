

provider "aws" {
    region = var.aws_region
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = var.s3_bucket_name

    versioning {
        enabled = true
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

resource "aws_s3_bucket_policy" "terraform_state_policy" {
    bucket = aws_s3_bucket.terraform_state.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Deny"
                Principal = "*"
                Action = "s3:*"
                Resource = [
                    "arn:aws:s3:::${aws_s3_bucket.terraform_state.bucket}",
                    "arn:aws:s3:::${aws_s3_bucket.terraform_state.bucket}/*"
                ]
                Condition = {
                    Bool = {
                        "aws:SecureTransport" = false
                    }
                }
            }
        ]
    })
}

resource "aws_dynamodb_table" "terraform_locks" {
    name         = var.dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}

terraform {
    backend "s3" {
        bucket         = var.s3_bucket_name
        key            = "terraform/state/terraform.tfstate"
        region         = var.aws_region
        dynamodb_table = var.dynamodb_table_name
        encrypt        = true
    }
}