

# EKS Cluster
resource "aws_eks_cluster" "example" {
    name = var.cluster_name

    access_config {
        authentication_mode = "API"
    }

    role_arn = aws_iam_role.cluster.arn
    version  = var.eks_version

    vpc_config {
        subnet_ids = var.subnet_ids
    }

    depends_on = [
        aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    ]
}

# IAM Role
resource "aws_iam_role" "cluster" {
    name = var.iam_role_name
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "sts:AssumeRole",
                    "sts:TagSession"
                ]
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            },
        ]
    })
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.cluster.name
}

