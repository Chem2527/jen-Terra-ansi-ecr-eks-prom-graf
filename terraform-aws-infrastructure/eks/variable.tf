variable "cluster_name" {
    description = "The name of the EKS cluster"
    type        = string
}

variable "region" {
    description = "The AWS region to deploy the EKS cluster"
    type        = string
    default     = "us-west-2"
}

variable "vpc_id" {
    description = "The VPC ID where the EKS cluster will be deployed"
    type        = string
}

variable "subnet_ids" {
    description = "The subnet IDs for the EKS cluster"
    type        = list(string)
}

variable "node_instance_type" {
    description = "The instance type for the worker nodes"
    type        = string
    default     = "t3.medium"
}

variable "desired_capacity" {
    description = "The desired number of worker nodes"
    type        = number
    default     = 2
}

variable "min_size" {
    description = "The minimum number of worker nodes"
    type        = number
    default     = 1
}

variable "max_size" {
    description = "The maximum number of worker nodes"
    type        = number
    default     = 3
}

variable "tags" {
    description = "A map of tags to add to resources"
    type        = map(string)
    default     = {}
}