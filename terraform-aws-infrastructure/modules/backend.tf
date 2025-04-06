terraform {
  backend "s3" {
    bucket         = "your-unique-tf-state-bucket"  # The S3 bucket you created
    key            = "terraform/state/terraform.tfstate"
    region         = "eu-north-1"  # The AWS region where the resources are
    dynamodb_table = "terraform-locks"  # The DynamoDB table for state locking
    encrypt        = true
  }
}
