variable "region" {
    description = "The AWS region to deploy the EKS cluster in."
    type        = string
    default     = "us-west-2"
}

variable "cluster_name" {
    description = "The name of the EKS cluster."
    type        = string
    default     = "my-eks-cluster"
}

variable "cluster_version" {
    description = "The Kubernetes version for the EKS cluster."
    type        = string
    default     = "1.24"
}

variable "subnets" {
    description = "A list of subnet IDs for the EKS cluster."
    type        = list(string)
    default     = []
}

variable "vpc_id" {
    description = "The VPC ID where the EKS cluster will be deployed."
    type        = string
    default     = ""
}

variable "desired_capacity" {
    description = "The desired number of nodes in the EKS node group."
    type        = number
    default     = 2
}

variable "max_capacity" {
    description = "The maximum number of nodes in the EKS node group."
    type        = number
    default     = 5
}

variable "min_capacity" {
    description = "The minimum number of nodes in the EKS node group."
    type        = number
    default     = 1
}

variable "instance_type" {
    description = "The EC2 instance type for the EKS nodes."
    type        = string
    default     = "t3.medium"
}

variable "key_name" {
    description = "The name of the SSH key pair to use for the EKS nodes."
    type        = string
    default     = ""
}

variable "tags" {
    description = "A map of tags to apply to resources."
    type        = map(string)
    default     = {}
}