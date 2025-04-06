# variables.tf
variable "sg_name" {
    description = "The name of the security group"
    type        = string
    default     = "default-sg-name"
}

variable "sg_description" {
    description = "The description of the security group"
    type        = string
    default     = "Default security group description"
}

variable "vpc_id" {
    description = "The VPC ID where the security group will be created"
    type        = string
    default     = "vpc-12345678"
}

variable "ingress_from_port" {
    description = "The starting port for ingress rules"
    type        = number
    default     = 80
}

variable "ingress_to_port" {
    description = "The ending port for ingress rules"
    type        = number
    default     = 80
}

variable "ingress_protocol" {
    description = "The protocol for ingress rules"
    type        = string
    default     = "tcp"
}

variable "ingress_cidr_blocks" {
    description = "The CIDR blocks for ingress rules"
    type        = list(string)
    default     = ["0.0.0.0/0"]
}

variable "egress_from_port" {
    description = "The starting port for egress rules"
    type        = number
    default     = 0
}

variable "egress_to_port" {
    description = "The ending port for egress rules"
    type        = number
    default     = 0
}

variable "egress_protocol" {
    description = "The protocol for egress rules"
    type        = string
    default     = "-1"
}

variable "egress_cidr_blocks" {
    description = "The CIDR blocks for egress rules"
    type        = list(string)
    default     = ["0.0.0.0/0"]
}

variable "sg_tags" {
    description = "Tags to assign to the security group"
    type        = map(string)
    default     = {
        "Environment" = "default"
        "Name"        = "default-sg"
    }
}