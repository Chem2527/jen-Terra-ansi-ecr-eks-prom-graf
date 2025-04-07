variable "security_group_name" {
    description = "The name of the security group"
    type        = string
}

variable "security_group_description" {
    description = "The description of the security group"
    type        = string
}

variable "vpc_id" {
    description = "The ID of the VPC where the security group will be created"
    type        = string
}

variable "ingress_from_port" {
    description = "The starting port for ingress rules"
    type        = number
}

variable "ingress_to_port" {
    description = "The ending port for ingress rules"
    type        = number
}

variable "ingress_protocol" {
    description = "The protocol for ingress rules (e.g., tcp, udp, icmp)"
    type        = string
}

variable "ingress_cidr_blocks" {
    description = "The CIDR blocks for ingress rules"
    type        = list(string)
}

variable "egress_from_port" {
    description = "The starting port for egress rules"
    type        = number
}

variable "egress_to_port" {
    description = "The ending port for egress rules"
    type        = number
}

variable "egress_protocol" {
    description = "The protocol for egress rules (e.g., tcp, udp, icmp)"
    type        = string
}

variable "egress_cidr_blocks" {
    description = "The CIDR blocks for egress rules"
    type        = list(string)
}

variable "tags" {
    description = "A map of tags to assign to the resource"
    type        = map(string)
}
