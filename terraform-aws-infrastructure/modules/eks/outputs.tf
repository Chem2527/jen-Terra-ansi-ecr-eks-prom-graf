# Outputs
output "eks_cluster_name" {
    description = "The name of the EKS cluster"
    value       = aws_eks_cluster.example.name
}

output "eks_cluster_endpoint" {
    description = "The endpoint of the EKS cluster"
    value       = aws_eks_cluster.example.endpoint
}

output "eks_cluster_arn" {
    description = "The ARN of the EKS cluster"
    value       = aws_eks_cluster.example.arn
}

output "eks_cluster_role_arn" {
    description = "The ARN of the IAM role associated with the EKS cluster"
    value       = aws_iam_role.cluster.arn
}