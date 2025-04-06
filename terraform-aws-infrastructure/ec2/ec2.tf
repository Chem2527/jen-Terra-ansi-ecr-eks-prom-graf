provider "aws" {
    region = var.aws_region
}

resource "aws_instance" "ec2_instance" {
    ami           = var.ami_id
    instance_type = var.instance_type
    key_name      = var.key_name

    tags = {
        Name = var.instance_name
    }

    # Optional block for security group
    vpc_security_group_ids = var.security_group_ids

    # Optional block for subnet
    subnet_id = var.subnet_id
}