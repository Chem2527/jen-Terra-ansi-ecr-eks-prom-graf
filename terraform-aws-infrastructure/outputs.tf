output "vpc_id" {
  value = module.vpc.vpc_id
}

output "security_group_id" {
  value = module.security_group.security_group_id
}

output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}
