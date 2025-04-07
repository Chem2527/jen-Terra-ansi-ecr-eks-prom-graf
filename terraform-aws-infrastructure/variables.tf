# VPC Variables
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}


variable "environment" {
    description = "The environment for the deployment (e.g., dev, prod)"
    type        = string
    default     = "dev"
}

variable "project_name" {
    description = "The name of the project"
    type        = string
    default     = "my-project"
}
variable "availability_zones" {
  description = "A list of availability zones"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "my-vpc"
}

# Security Group Variables
variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "my-security-group"
}

variable "security_group_description" {
  description = "The description of the security group"
  type        = string
  default     = "Security group for EC2 instances"
}

variable "ingress_from_port" {
  description = "The port to allow ingress from"
  type        = number
  default     = 22
}

variable "ingress_to_port" {
  description = "The port to allow ingress to"
  type        = number
  default     = 22
}

variable "ingress_protocol" {
  description = "The protocol to allow ingress"
  type        = string
  default     = "tcp"
}

variable "ingress_cidr_blocks" {
  description = "The CIDR blocks for ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "egress_from_port" {
  description = "The port to allow egress from"
  type        = number
  default     = 0
}

variable "egress_to_port" {
  description = "The port to allow egress to"
  type        = number
  default     = 0
}

variable "egress_protocol" {
  description = "The protocol to allow egress"
  type        = string
  default     = "-1"
}

variable "egress_cidr_blocks" {
  description = "The CIDR blocks for egress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# EC2 Instance Variables
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default = "ami-0c1ac8a41498c1a9c"  # Replace with a valid AMI ID
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
  default = "saikrishna2527"
}

variable "volume_size" {
  description = "The size of the root volume (in GB)"
  type        = number
  default     = 8
}

variable "volume_type" {
  description = "The type of the root volume"
  type        = string
  default     = "gp2"
}

variable "instance_name" {
  description = "The name of the EC2 instance"
  type        = string
  default     = "my-instance"
}

variable "additional_tags" {
  description = "Additional tags for the EC2 instance"
  type        = map(string)
  default     = {}
}

# EKS Variables
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default = "saikrishna2527"
}

variable "eks_version" {
  description = "The version of the EKS cluster"
  type        = string
  default     = "1.32"
}

# S3 Bucket for Terraform State Variables
variable "s3_bucket_name" {
    description = "The name of the S3 bucket for Terraform state"
    type        = string
    default     = "new-terraform-state-bucket-name"
}

# DynamoDB Table for Locking Variables
variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  type        = string
  default = "terraform-locks"  # Replace with your desired table name
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "eu-north-1"  # Replace with your desired default region
}


