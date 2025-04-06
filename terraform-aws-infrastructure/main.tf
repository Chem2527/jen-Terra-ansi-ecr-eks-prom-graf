# VPC Module
module "vpc" {
  source = "./modules/vpc"  # Reference the VPC module
  cidr_block = var.vpc_cidr_block
  # Add other variables required by the VPC module (e.g., subnets, NAT gateway, etc.)
}

# Security Group Module
module "security_group" {
  source = "./modules/security group"  # Reference the security group module
  vpc_id = module.vpc.vpc_id  # Reference VPC ID from the VPC module
  sg_name = var.sg_name
  sg_description = var.sg_description
  # Add other variables required by the security group module
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"  # Reference the EC2 module
  instance_type = var.instance_type
  ami_id = var.ami_id
  key_name = var.key_name
  subnet_id = module.vpc.public_subnet_ids[0]  # Assuming you're getting public subnet IDs from the VPC module
  security_group_ids = [module.security_group.security_group_id]  # Pass SG ID from the security group module
  tags = var.instance_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"  # Reference the EKS module
  cluster_name = var.eks_cluster_name
  node_group_name = var.node_group_name
  # Add other variables required by the EKS module
}

# S3 Module (for storing Terraform state or other purposes)
module "s3" {
  source = "./modules/s3"  # Reference the S3 module
  bucket_name = var.s3_bucket_name
  # Add other variables required by the S3 module
}