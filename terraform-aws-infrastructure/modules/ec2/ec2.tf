provider "aws" {
    region = var.region
}

resource "aws_instance" "ec2_instance" {
    ami                         = var.ami_id
    instance_type               = var.instance_type
    key_name                    = var.key_name
    subnet_id                   = var.subnet_id
    associate_public_ip_address = var.associate_public_ip
    security_groups             = var.security_groups

    root_block_device {
        volume_size = var.volume_size
        volume_type = var.volume_type
    }

    tags = merge(
        {
            Name = var.instance_name
        },
        var.additional_tags
    )
}

