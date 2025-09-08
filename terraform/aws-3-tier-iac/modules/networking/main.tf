# VPC, IGW, NAT, 3×AZs, 3×subnets per AZ, 2xRTs, subnets groups


## VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    {
      Name = "${var.name}-vpc"
    },
    var.tags,
  )
}

## Internet Gateway
resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id
    tags = merge(
      {
        Name = "${var.name}-igw"
      },
      var.tags,
    )
}

## Public Subnets - Web Tier - 1 per AZ
resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    {
      Name = "${var.name}-public-${element(var.azs, count.index)}"
    },
    var.tags,
  )
}

## App Subnets - App Tier - 1 per AZ
resource "aws_subnet" "app" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(
    {
      Name = "${var.name}-app-${element(var.azs, count.index)}"
    },
    var.tags,
  )
}

## DB Subnets - DB Tier - 1 per AZ
resource "aws_subnet" "db" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(
    {
      Name = "${var.name}-db-${element(var.azs, count.index)}"
    },
    var.tags,
  )
}

## NAT Gateways - 1 per AZ - optional
resource "aws_eip" "nat" {
  count      = var.create_natgw_per_az ? length(var.azs) : 1
  domain = "vpc"
  depends_on = [aws_internet_gateway.this]
  tags = merge(
    {
      Name = "${var.name}-nat-eip-${count.index}"
    },
    var.tags,
  )
}

resource "aws_nat_gateway" "this" {
  count         = var.create_natgw_per_az ? length(var.azs) : 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public[*].id, count.index)
#   subnet_id     = aws_subnet.public[count.index].id   # alternate way
  tags = merge(
    {
      Name = "${var.name}-natgw-${count.index}"
    },
    var.tags,
  )
  depends_on = [aws_internet_gateway.this]
}

## Route Tables
# Public RT - 1 per AZ
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    {
      Name = "${var.name}-public-rt"
    },
    var.tags,
  )
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

# Private RT - 1 per AZ
resource "aws_route_table" "private" {
    count = length(var.azs)
    vpc_id = aws_vpc.this.id
    tags = merge(
        {
            Name = "${var.name}-private-rt-${element(var.azs, count.index)}"
        },
        var.tags
    )
}

resource "aws_route" "private_nat_access" {
  count             = length(var.azs)
  route_table_id    = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = var.create_natgw_per_az ? aws_nat_gateway.this[count.index].id : aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "app_assoc" {
    count           = length(var.azs)
    subnet_id       = aws_subnet.app[count.index].id
    route_table_id  = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "db_assoc" {
  count             = length(var.azs)
  subnet_id         = aws_subnet.db[count.index].id
  route_table_id    = aws_route_table.private[count.index].id
}

## Subnet Groups for RDS & ElastiCache
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = aws_subnet.db[*].id
  tags = merge(
    {
      Name = "${var.name}-db-subnet-group"
    },
    var.tags,
  )
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-redis-subnet-group"
  subnet_ids = aws_subnet.app[*].id
  tags = merge(
    {
      Name = "${var.name}-redis-subnet-group"
    },
    var.tags,
  )
}