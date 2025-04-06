locals {
    ingress_rules = [
        {
            description = "Allow HTTP traffic"
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        },
        {
            description = "Allow HTTPS traffic"
            from_port   = 443
            to_port     = 443
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    ]
}

resource "aws_security_group" "example" {
    name        = "example-security-group"
    description = "Security group for example application"
    vpc_id      = var.vpc_id

    dynamic "ingress" {
        for_each = local.ingress_rules
        content {
            description = ingress.value.description
            from_port   = ingress.value.from_port
            to_port     = ingress.value.to_port
            protocol    = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_blocks
        }
    }

    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name        = "example-security-group"
        Environment = var.environment
    }
}