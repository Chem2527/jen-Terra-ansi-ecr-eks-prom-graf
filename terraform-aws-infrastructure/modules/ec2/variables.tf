variable "region" {
    description = "The AWS region to deploy resources in"
    type        = string
}

variable "ami_id" {
    description = "The AMI ID to use for the EC2 instance"
    type        = string
}

variable "instance_type" {
    description = "The type of instance to create"
    type        = string
}

variable "key_name" {
    description = "The key pair name to use for the instance"
    type        = string
}

variable "instance_name" {
    description = "The name tag for the EC2 instance"
    type        = string
}

variable "additional_tags" {
    description = "Additional tags to apply to the EC2 instance"
    type        = map(string)
    default     = {}
}

variable "subnet_id" {
    description = "The subnet ID to launch the instance in"
    type        = string
}

variable "associate_public_ip" {
    description = "Whether to associate a public IP address with the instance"
    type        = bool
}

variable "security_groups" {
    description = "The security groups to associate with the instance"
    type        = list(string)
}

variable "volume_size" {
    description = "The size of the root volume in GB"
    type        = number
}

variable "volume_type" {
    description = "The type of the root volume"
    type        = string
}
