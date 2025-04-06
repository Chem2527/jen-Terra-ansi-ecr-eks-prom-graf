provider "aws" {
    region = var.aws_region
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = var.s3_bucket_name

    versioning {
        enabled = true
    }

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
    name         = var.dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }

    lifecycle {
        prevent_destroy = true
    }
}

terraform {
    backend "s3" {
        bucket         = var.s3_bucket_name
        key            = var.s3_key
        region         = var.aws_region
        dynamodb_table = var.dynamodb_table_name
        encrypt        = true
    }
}