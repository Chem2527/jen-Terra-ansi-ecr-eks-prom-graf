# Outputs
output "eks_cluster_name" {
    description = "The name of the EKS cluster"
    value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
    description = "The endpoint of the EKS cluster"
    value       = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
    description = "The ARN of the EKS cluster"
    value       = module.eks.cluster_arn
}

# output "eks_cluster_role_arn" {
#     description = "The ARN of the IAM role associated with the EKS cluster"
#     value       = module.eks.cluster_role_arn
# }

output "cluster_id" {
  value = module.eks.cluster_id
}
