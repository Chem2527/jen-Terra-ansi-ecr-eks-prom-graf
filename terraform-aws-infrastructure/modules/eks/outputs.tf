output "cluster_id" {
    description = "The ID of the EKS cluster."
    value       = module.eks.cluster_id
}

output "cluster_arn" {
    description = "The ARN of the EKS cluster."
    value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
    description = "The endpoint for the EKS Kubernetes API."
    value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
    description = "Security group ID attached to the EKS cluster."
    value       = module.eks.cluster_security_group_id
}

output "node_group_arns" {
    description = "ARNs of the EKS managed Node Groups."
    value       = module.eks.node_group_arns
}

output "node_group_names" {
    description = "Names of the EKS managed Node Groups."
    value       = module.eks.node_group_names
}

output "kubeconfig" {
    description = "Kubeconfig file content to connect to the EKS cluster."
    value       = module.eks.kubeconfig
}

output "eks_cluster_version" {
    description = "The Kubernetes version of the EKS cluster."
    value       = module.eks.cluster_version
}