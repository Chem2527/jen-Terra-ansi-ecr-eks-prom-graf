resource "aws_vpc" "main" {
    cidr_block           = var.vpc_cidr
    enable_dns_support   = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames
    tags = merge(
        {
            "Name" = var.vpc_name
        },
        var.tags
    )
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = merge(
        {
            "Name" = "${var.vpc_name}-igw"
        },
        var.tags
    )
}

resource "aws_subnet" "public" {
    count                   = length(var.public_subnet_cidrs)
    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.public_subnet_cidrs[count.index]
    map_public_ip_on_launch = true
    availability_zone       = element(var.availability_zones, count.index)
    tags = merge(
        {
            "Name" = "${var.vpc_name}-public-${count.index}"
        },
        var.tags
    )
}

resource "aws_subnet" "private" {
    count             = length(var.private_subnet_cidrs)
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.private_subnet_cidrs[count.index]
    availability_zone = element(var.availability_zones, count.index)
    tags = merge(
        {
            "Name" = "${var.vpc_name}-private-${count.index}"
        },
        var.tags
    )
}

