# Variables
variable "cluster_name" {
    description = "The name of the EKS cluster"
    type        = string
    default     = "example"
}

variable "eks_version" {
    description = "The version of the EKS cluster"
    type        = string
    default     = "1.31"
}

variable "subnet_ids" {
    description = "List of subnet IDs for the EKS cluster"
    type        = list(string)
}

variable "iam_role_name" {
    description = "The name of the IAM role for the EKS cluster"
    type        = string
    default     = "eks-cluster-example"
}