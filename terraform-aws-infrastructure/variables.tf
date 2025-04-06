# Define variables with default values

# VPC Variables
variable "vpc_cidr_block" {
    description = "CIDR block for the VPC"
    default     = "10.0.0.0/16"
}

# Security Group Variables
variable "sg_name" {
    description = "Name of the security group"
    default     = "default-sg"
}

variable "sg_description" {
    description = "Description of the security group"
    default     = "Default security group"
}

# EC2 Variables
variable "instance_type" {
    description = "Type of EC2 instance"
    default     = "t2.micro"
}

variable "ami_id" {
    description = "AMI ID for the EC2 instance"
    default     = "ami-12345678"  # Replace with a valid AMI ID
}

variable "key_name" {
    description = "Key pair name for EC2 instance access"
    default     = "default-key"
}

variable "instance_tags" {
    description = "Tags to apply to the EC2 instance"
    default     = {
        Name = "default-ec2"
    }
}

# EKS Variables
variable "eks_cluster_name" {
    description = "Name of the EKS cluster"
    default     = "default-eks-cluster"
}

variable "node_group_name" {
    description = "Name of the EKS node group"
    default     = "default-node-group"
}

# S3 Variables
variable "s3_bucket_name" {
    description = "Name of the S3 bucket"
    default     = "default-s3-bucket"
}
variable "aws_region" {
    description = "AWS region for the S3 bucket"
    default     = "us-west-2"
  
}