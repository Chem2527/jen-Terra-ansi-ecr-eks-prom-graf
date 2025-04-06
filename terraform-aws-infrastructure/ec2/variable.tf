variable "instance_type" {
    description = "The type of instance to use"
    type        = string
    default     = "t2.micro"
}

variable "ami_id" {
    description = "The AMI ID to use for the instance"
    type        = string
}

variable "key_name" {
    description = "The key pair name to use for the instance"
    type        = string
}

variable "subnet_id" {
    description = "The subnet ID where the instance will be deployed"
    type        = string
}

variable "security_group_ids" {
    description = "A list of security group IDs to associate with the instance"
    type        = list(string)
}

variable "tags" {
    description = "A map of tags to assign to the instance"
    type        = map(string)
    default     = {}
}
variable "instance_name" {
    description = "The name of the instance"
    type        = string
    default     = "my-instance"
  
}
variable "aws_region" {
    description = "The AWS region to deploy the instance in"
    type        = string
    default     = "us-east-1"
  
}