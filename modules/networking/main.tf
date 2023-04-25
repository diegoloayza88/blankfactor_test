################################################################################
# VPC
################################################################################

data "aws_availability_zone" "this" {
  for_each = toset(var.azs)
  name     = each.value
}

locals {
  azs_short = [for zone in data.aws_availability_zone.this : zone.name_suffix]
}

resource "aws_vpc" "test_bf_vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true

  tags = merge(
    { "Name" = "${upper(var.name)}-${upper(var.region)}" },
    var.tags
  )
}

################################################################################
# Private subnet
################################################################################

resource "aws_subnet" "private" {
  for_each          = toset(var.azs)
  cidr_block        = cidrsubnet(var.cidr, 3, index(var.azs, each.value))
  availability_zone = each.value
  vpc_id            = aws_vpc.test_bf_vpc.id
  tags = merge(
    {
      "Name" = "${upper(var.name)}-PRIVATE-${upper(each.value)}",
      tier   = "private"
    },
    var.tags
  )
}

################################################################################
# Public subnet
################################################################################

resource "aws_subnet" "public" {
  for_each          = toset(var.azs)
  cidr_block        = cidrsubnet(var.cidr, 5, 16 + index(var.azs, each.value))
  availability_zone = each.value
  vpc_id            = aws_vpc.test_bf_vpc.id
  tags = merge(
    {
      "Name" = "${upper(var.name)}-PUBLIC-${upper(each.value)}",
      tier   = "public"
    },
    var.tags
  )
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.test_bf_vpc.id

  tags = merge(
    { "Name" = "${upper(var.name)}-IGW" },
    var.tags
  )
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_eip" "nat" {
  for_each = toset(var.azs)
  vpc      = true

  tags = merge(
    {
      "Name" = "${upper(var.name)}-NAT-EIP-${upper(each.value)}",
    },
    var.tags
  )
}

resource "aws_nat_gateway" "this" {
  for_each      = toset(var.azs)
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(
    {
      "Name" = "${upper(var.name)}-NATGW-${upper(each.value)}",
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

################################################################################
# Private routes
# There are as many routing tables as the number of NAT gateways
################################################################################

resource "aws_route_table" "private" {
  for_each = toset(var.azs)
  vpc_id   = aws_vpc.test_bf_vpc.id

  tags = merge(
    {
      "Name" = "${upper(var.name)}-PRIVATE-${upper(each.value)}",
    },
    var.tags
  )
}

resource "aws_route" "private_nat_gateway" {
  for_each               = toset(var.azs)
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id

  timeouts {
    create = "5m"
  }
}

################################################################################
# Public routes
################################################################################

resource "aws_route_table" "public" {
  for_each = toset(var.azs)
  vpc_id   = aws_vpc.test_bf_vpc.id

  tags = merge(
    {
      "Name" = "${upper(var.name)}-PUBLIC-${upper(each.value)}"
    },
    var.tags
  )
}

resource "aws_route" "public_internet_gateway" {
  for_each               = toset(var.azs)
  route_table_id         = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

################################################################################
# Route table associations
################################################################################

resource "aws_route_table_association" "private" {
  for_each       = toset(var.azs)
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "public" {
  for_each       = toset(var.azs)
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}